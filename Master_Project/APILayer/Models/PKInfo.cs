using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace APILayer.Models
{
    public class PKInfo : IEnumerable
    {
        public PKInfo(string table, int value)
        {
            PkTable = table;
            PkValue = value;
        }

        public string PkTable { get; set; }
        public int PkValue { get; set; }
       
        public IEnumerator GetEnumerator()
        {
            return (IEnumerator)GetEnumerator();
        }
    }
}
