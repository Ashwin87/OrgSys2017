using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace APILayer.Models
{
    public class QueryField
    {
        public int FieldID { get; set; }
        public int FieldOrder { get; set; }
        public string FieldLabel { get; set; }
        public string ColumnAlias { get; set; }
        public string PKTable { get; set; }
        public string PKName { get; set; }
        public string FKName { get; set; }
        public int TableOrder { get; set; }
        public string TableName { get; set; }
        public string ColumnName { get; set; }
        public int IsVisible { get; set; }
    }
}