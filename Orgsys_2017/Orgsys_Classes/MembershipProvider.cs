using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Security.Cryptography;
using System.Text;
using DataLayer;

namespace Orgsys_2017.Orgsys_Classes
{
    public class MembershipProvider {
        //CreateNewSalt() uses a random number generator to create a 33 byte integer to append onto the hash

        public static byte[] CreateNewSalt() {
            RNGCryptoServiceProvider crypto = new RNGCryptoServiceProvider();
            byte[] salt = new byte[33];
            crypto.GetNonZeroBytes(salt);
            return salt;
        }

        public static String CreateNewSaltString() { //used to add to DB
            try { 
            RNGCryptoServiceProvider crypto = new RNGCryptoServiceProvider();
            byte[] salt = new byte[33];
            crypto.GetNonZeroBytes(salt);
            return Convert.ToBase64String(salt);
            }
            catch (Exception ex)
            {
                ExceptionLogger.LogException(ex);
                return "";
            }
        }
        //GenerateHash() grabs the salt, and the plain text password and prepares to encrypt it
        public static string GenerateHash(string plainText,byte[] saltBytes) {
            try {
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
            catch (Exception ex)
            {
                ExceptionLogger.LogException(ex);
                return "";
            }

        }
        public static bool VerifyHash(string plainText,string hashValue) {
            // bool functionReturnValue = false;
            // Convert base64-encoded hash value into a byte array.
            try { 
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
            // return (hashValue == expectedHashString);
            //  return functionReturnValue;
        } catch(Exception ex) {
           ExceptionLogger.LogException(ex);
           return false; 
        }
}
   
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
           ExceptionLogger.LogException(ex);
           return false; 
        }
      }
   }
}