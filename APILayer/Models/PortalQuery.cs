using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace APILayer.Models
{
    public class PortalQuery
    {
        public PortalQuery(string table)
        {
            TableName = table;
        }

        public List<string> paramNameList { get; set; } = new List<string>();
        public List<string> paramValuePlaceList { get; set; } = new List<string>();
        public List<object> paramValueList { get; set; } = new List<object>();
        public string TableName { get; set; }

        /// <summary>
        /// Adds a parameter to this query.
        /// </summary>
        /// <param name="name"></param>
        /// <param name="value"></param>
        public void AddParameter(string name, object value)
        {
            paramNameList.Add(name);
            paramValuePlaceList.Add("@" + name);
            paramValueList.Add(value);
        }

        /// <summary>
        /// Returns insert statement with column names and value placeholders.
        /// </summary>
        /// <returns></returns>
        public string GetCommandText()
        {
            return $"INSERT INTO {TableName} ({string.Join(", ", paramNameList)}) VALUES({string.Join(", ", paramValuePlaceList)}); SELECT SCOPE_IDENTITY();";
        }

        /// <summary>
        /// Concatenates parameters that save into a particular column with a delimiter.
        /// </summary>
        /// <param name="column"></param>
        /// <param name="delimiter"></param>
        public void ConcatenateParameters(string column, string delimiter)
        {
            var concatenatedValueList = new List<string>();
            var count = paramNameList.FindAll(x => x == column).Count;          //the fields to be concatenated will have the same Name value

            if (count > 0)
            {
                while (count != 0)
                {
                    //will be concatenated in the order in which they are found
                    var index = paramNameList.FindIndex(x => x == column);      //related items stored at same index in other lists
                    concatenatedValueList.Add((string)paramValueList[index]);

                    paramNameList.RemoveAt(index);
                    paramValuePlaceList.RemoveAt(index);
                    paramValueList.RemoveAt(index);

                    count--;
                }

                AddParameter(column, string.Join(delimiter, concatenatedValueList));
            }
        }

        public int ExecuteInsert(SqlConnection connection)
        {
            using (var command = connection.CreateCommand())
            {
                command.CommandText = GetCommandText();
                for (var i = 0; i < paramValueList.Count; i++)
                {
                    command.Parameters.AddWithValue(paramValuePlaceList[i], paramValueList[i]);
                }

                //command.ExecuteNonQuery();
                return int.Parse(command.ExecuteScalar().ToString());
            }
        }
    }
}