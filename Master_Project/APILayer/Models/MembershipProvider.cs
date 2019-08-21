using System;
using System.Security.Cryptography;
using System.Text;
using DataLayer;
using Newtonsoft.Json;
using System.Collections.Generic;

//* Author         : Marie Gougeon
//* Created        : 01-12-2017
//* Update Date    : 2018-03-21 - Marie
//* Description    : Classes to grab Salt & Hash from the DB, Create Tokens, Generating Hash and Salt for Passwords, Verifying the Hash provided and Logging success attempts

namespace Orgsys_2017.Orgsys_Classes{
   
    public class MembershipProvider {

        //getters setters for hash & salt
        public class Device
        {
            public string SHASalt { get; set; }
            public string SHAHash { get; set; }
        }

        public class OldHash
        {
            public string SHAHash { get; set; }
        }
       
        //grab the salt that is used for this user's password provided
        public static string GetSalt(string UserID){
            try {
            OrgSys2017DataContext con = new OrgSys2017DataContext();
            var Salt = JsonConvert.SerializeObject(con.GetSalt(UserID), Formatting.None);
            var SaltReturn = JsonConvert.DeserializeObject<List<Device>>(Salt);

            return SaltReturn[0].SHASalt;

            } catch (Exception ex){
                ExceptionLog.LogException(ex);
                return "0";
            }
           
        }

        //grab the hash that is used for this user's password provided
        public static string GetHash(string UserID)
        {
            try
            {
                OrgSys2017DataContext con = new OrgSys2017DataContext();
                var Hash = JsonConvert.SerializeObject(con.GetHash(UserID), Formatting.None);
                var HashReturn = JsonConvert.DeserializeObject<List<Device>>(Hash);

                return HashReturn[0].SHAHash;
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return "0";
            }

        }

        public static string GetOldHash(int HashID)
        {
            try
            {
                OrgSys2017DataContext con = new OrgSys2017DataContext();
                var Hash = JsonConvert.SerializeObject(con.SessionTransfer_GET(HashID), Formatting.None);
                var HashReturn = JsonConvert.DeserializeObject<List<OldHash>>(Hash);

                return HashReturn[0].SHAHash;
            }
            catch (Exception ex)
            {
                ExceptionLog.LogException(ex);
                return "0";
            }

        }

        //Generate a token - will be used for multiple session updates
        public static string createToken()
        { 
            const string valid = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
            StringBuilder res = new StringBuilder();
            int length = 22;
            using (RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider())
            {
                byte[] uintBuffer = new byte[sizeof(uint)];

                while (length-- > 0)
                {
                    rng.GetBytes(uintBuffer);
                    uint num = BitConverter.ToUInt32(uintBuffer, 0);
                    res.Append(valid[(int)(num % (uint)valid.Length)]);
                }
            }

            return res.ToString();
        }

        //CreateNewSalt uses a number & character generator to create a 33 byte integer to append onto the hash - SHA2 compliant
        public static byte[] CreateNewSalt() {
            RNGCryptoServiceProvider crypto = new RNGCryptoServiceProvider();
            byte[] salt = new byte[33];
            crypto.GetNonZeroBytes(salt);
            return salt;
        }
        //CreateNewSaltString uses a number& character generator to create a 33 byte integer to append onto the hash - SHA2 compliant
        //Used to return it in string form instead if need - used to create new passwords
        public static String CreateNewSaltString() {
            RNGCryptoServiceProvider crypto = new RNGCryptoServiceProvider();
            byte[] salt = new byte[33];
            crypto.GetNonZeroBytes(salt);
            return Convert.ToBase64String(salt);
        }
        //GenerateHash grabs the salt, and the plain text password and prepares to encrypt it
        //Used to take the users input and salt generated based on the password given - used to create new passwords
        public static string GenerateHash(string plainText,byte[] saltBytes) {
            if((saltBytes == null)) {
                saltBytes = CreateNewSalt();
            }
            //plain text is the password, and it is put into bytes
            byte[] plainTextBytes = null;
            plainTextBytes = Encoding.UTF8.GetBytes(plainText);
            //tge salt bytes and hash bytes are combined
            byte[] plainTextWithSaltBytes = new byte[plainTextBytes.Length + saltBytes.Length];

            int i = 0; //filling the array's salt bytes
            for(i = 0; i <= plainTextBytes.Length - 1; i++) {
                plainTextWithSaltBytes[i] = plainTextBytes[i];
            }

            // Append salt bytes to the resulting array.
            for(i = 0; i <= saltBytes.Length - 1; i++) {
                plainTextWithSaltBytes[plainTextBytes.Length + i] = saltBytes[i];
            }

            HashAlgorithm hash = default(HashAlgorithm); //cryptography hash Algorithm
            hash = new SHA512Managed(); //Initializes a new instance of the SHA512Managed class.


            // Compute hash value of our plain text with appended salt.
            byte[] hashBytes = null;
            hashBytes = hash.ComputeHash(plainTextWithSaltBytes);

            // Create array which will hold hash and original salt bytes.
            byte[] hashWithSaltBytes = new byte[hashBytes.Length + saltBytes.Length];

            // Copy hash bytes into resulting array.
            for(i = 0; i <= hashBytes.Length - 1; i++) {
                hashWithSaltBytes[i] = hashBytes[i];
            }

            // Append salt bytes to the result.
            for(i = 0; i <= saltBytes.Length - 1; i++) {
                hashWithSaltBytes[hashBytes.Length + i] = saltBytes[i];
            }

            // Convert result into a base64-encoded string.
            string hashValue = null;
            hashValue = Convert.ToBase64String(hashWithSaltBytes);

            // Return the result.
            return hashValue;

        }

        //This method will take the password from User trying to log in and compaare it to the hashvalue from the username's valid userid
        //TLDR; the given password is hashed and compared with the other hash
        public static bool VerifyHash(string plainText,string hashValue) {

            // Convert base64-encoded hash value into a byte array.
            byte[] hashWithSaltBytes = null;
            hashWithSaltBytes = Convert.FromBase64String(hashValue);

            // We must know size of hash (without salt).
            int hashSizeInBits = 0;
            int hashSizeInBytes = 0;

            hashSizeInBits = 512;

            // Convert size of hash from bits to bytes.
            hashSizeInBytes = hashSizeInBits / 8;

            // Make sure that the specified hash value is long enough.
            if((hashWithSaltBytes.Length < hashSizeInBytes)) {
                return false;
            }

            // Allocate array to hold original salt bytes retrieved from hash.
            byte[] saltBytes = new byte[hashWithSaltBytes.Length - hashSizeInBytes];

            // Copy salt from the end of the hash to the new array.
            int i = 0;
            for(i = 0; i <= saltBytes.Length - 1; i++) {
                saltBytes[i] = hashWithSaltBytes[hashSizeInBytes + i];
            }

            // Compute a new hash string.
            string expectedHashString = null;
            expectedHashString = GenerateHash(plainText,saltBytes);

            if(hashValue == expectedHashString) {
                return true;
            } else {
                return false;
            }

            // If the computed hash matches the specified hash,
            // the plain text value must be correct.

        }
   
    //NEED TO REVISE - IGNORE FOR NOW------------------
    public static bool LogUser(int UserID, bool Success, string message) {
        try{ //if successful login
            OrgSys2017DataContext con = new OrgSys2017DataContext();
            if (Success == true) { 
                //Create new Log object
                Log ulog = new Log();
                ulog.UserID = UserID;
                ulog.LogDateTime = DateTime.Now;
                ulog.Event = message;

                //add row to Log database
                con.Logs.InsertOnSubmit(ulog);
                con.SubmitChanges();
                return true;
            } else { //if unsuccessful login
                //Create new Log object
                Log ulog = new Log();
                ulog.UserID = UserID;
                ulog.LogDateTime = DateTime.Now;
                ulog.Event = message;

                //add row to Log database
                con.Logs.InsertOnSubmit(ulog);
                con.SubmitChanges();
                return false;
            }
        } catch(Exception ex) {
           ExceptionLog.LogException(ex);
           return false; 
        }
      }
   }
}