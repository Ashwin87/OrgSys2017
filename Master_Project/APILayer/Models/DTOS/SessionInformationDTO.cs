using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace APILayer.Models.DTOS
{
    public class SessionInformationDTO
    {
        public string _DateCreated { get; set; }    
        public string _DateLastActive { get; set; }
        public string Token { get; set; }
    }
}