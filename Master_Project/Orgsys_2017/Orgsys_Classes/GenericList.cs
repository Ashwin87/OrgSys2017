using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Orgsys_2017.Orgsys_Classes
{
    /// <summary>
    /// It creates a generic class having key and value as properties.
    /// </summary>
    public class GenericList:IEnumerable
    {
        public Type tableName { get; set; }
        public object tableObj { get; set; }

        public IEnumerator GetEnumerator()
        {
            return (IEnumerator)GetEnumerator();
        }
    }
}