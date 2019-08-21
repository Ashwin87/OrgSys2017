using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Orgsys_2017.Orgsys_Classes
{
    /// <summary>
    /// It stores the table Info
    /// </summary>
    public class RecordInsertion:IEnumerable
    {
        public string TableName{ get; set; }
        public  bool Inserted { get; set; }
        public int PrimaryKey { get; set; }
        public IEnumerator GetEnumerator()
        {
            return (IEnumerator)GetEnumerator();
        }
    }
}