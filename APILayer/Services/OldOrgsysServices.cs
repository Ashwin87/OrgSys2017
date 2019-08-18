using System;
using System.Data;
using MySql.Data.MySqlClient;
using APILayer.Models;

namespace APILayer.Services
{
    public class OldOrgsysServices
    {
        private MySqlConnection _connection;
        private MySqlTransaction _transaction;

        public OldOrgsysServices(MySqlConnection connection, MySqlTransaction transaction)
        {
            _connection = connection;
            _transaction = transaction;
        }

        public OldOrgsysServices(MySqlConnection connection)
        {
            _connection = connection;
        }

        /// <summary>
        /// Calls database function to encrypt a string.
        /// </summary>
        /// <param name="cleartext"></param>
        public object EncryptString(string cleartext)
        {
            using (var command = _connection.CreateCommand())
            {
                command.CommandText = "OSI_New.fn_EncryptString";
                command.CommandType = CommandType.StoredProcedure;

                command.Parameters.AddWithValue("@strToEncrypt", cleartext);
                command.Parameters["@strToEncrypt"].Direction = ParameterDirection.Input;

                command.Parameters.Add("@RETURN_VALUE", MySqlDbType.Blob);
                command.Parameters["@RETURN_VALUE"].Direction = ParameterDirection.ReturnValue;

                command.ExecuteNonQuery();

                return command.Parameters["@RETURN_VALUE"].Value;
            }
        }

        /// <summary>
        /// Returns EmployeedID of record that matches parameters, 0 if no record found.
        /// </summary>
        /// <param name="importId"></param>
        /// <param name="firstName"></param>
        /// <param name="lastName"></param>
        /// <param name="dob"></param>
        public int GetEmployeeID(int importId, string firstName, string lastName, string dob = null)
        {
            using (var command = _connection.CreateCommand())
            {
                if (dob != null)
                {
                    command.CommandText = "OSI_New.PORTALORG_GetEmployeeIDByNameAndDOB";
                    command.Parameters.AddWithValue("@employeeDOB", dob);
                    command.Parameters["@employeeDOB"].Direction = ParameterDirection.Input;
                }
                else
                {
                    command.CommandText = "OSI_New.PORTALORG_GetEmployeeIDByName";
                }

                command.CommandType = CommandType.StoredProcedure;

                command.Parameters.AddWithValue("@employeeLast", lastName);
                command.Parameters["@employeeLast"].Direction = ParameterDirection.Input;

                command.Parameters.AddWithValue("@employeeFirst", firstName);
                command.Parameters["@employeeFirst"].Direction = ParameterDirection.Input;                

                command.Parameters.AddWithValue("@importId", importId);
                command.Parameters["@importId"].Direction = ParameterDirection.Input;

                var id = command.ExecuteScalar();

                return (id == null) ? 0 : (int)id;
            }
        }
        
        /// <summary>
        /// Returns the claims index value of the claim to be submitted.
        /// </summary>
        /// <param name="employeeId"></param>
        public int GetClaimIndexByEmployeeID(int employeeId)
        {
            using (var command = _connection.CreateCommand())
            {
                command.CommandText = "SELECT COUNT(*) FROM OSI_New.os_claims WHERE EmployeeID = @employeeId AND ArchivedRecord = 0 AND FileArchived = 0;";
                command.Parameters.AddWithValue("@employeeId", employeeId);

                var result = command.ExecuteScalar();

                return int.Parse(result.ToString()) + 1;
            }
        }

        /// <summary>
        /// Return the id value of the last inserted record for the connection passed.
        /// </summary>
        public int GetLastInsertID()
        {
            using (var command = _connection.CreateCommand())
            {
                command.CommandText = "SELECT LAST_INSERT_ID();";
                var id = int.Parse(command.ExecuteScalar().ToString());

                return id;
            }
        }

        /// <summary>
        /// Builds and executes the query.
        /// </summary>
        /// <param name="query"></param>
        public void ExecuteInsert(PortalQuery query)
        {
            using (var command = _connection.CreateCommand())
            {
                command.Transaction = _transaction;
                command.CommandText = query.GetCommandText();
                for (var i = 0; i < query.paramValueList.Count; i++)
                {
                    command.Parameters.AddWithValue(query.paramValuePlaceList[i], query.paramValueList[i]);
                }

                command.ExecuteNonQuery();
            }
        }
    }
}