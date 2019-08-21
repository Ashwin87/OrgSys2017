using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using DataLayer;

namespace Orgsys_2017.Orgsys_Classes
{
    public partial class OSI_Page : System.Web.UI.Page
    {
        public static string get_api 
        {
            get
            {
                if (HttpContext.Current.Request.Url.Host == "localhost")
                {
                    return "http://localhost:49627";
                    //return "https://api02.orgsoln.com";
                }
                else if(HttpContext.Current.Request.Url.Host == "umbrella02.orgsoln.com")
                {
                    return "https://api02.orgsoln.com";
                }
                else if (HttpContext.Current.Request.Url.Host == "orgsolutions.orgsoln.com")
                {
                    return "https://api02.orgsoln.com";
                }
                else
                {
                    return "https://apidev01.orgsoln.com";
                }
            }
        }

        public static string get_recaptcha_key
        {
            get
            {
                if (HttpContext.Current.Request.Url.Host == "localhost")
                {
                    return "6Lfc1xUUAAAAAKlVZs31qpQMl7DDz2jnn1T7iLeE";
                }
                else
                {
                    return "6Lcl2BUUAAAAAPfiRMwZc0mPBoCjhEvS0cTbExh5";
                }
            }
        }

           public static string token
           {
               get
               {
                   return HttpContext.Current.Session["token"].ToString();
               }
           }

           public static string  ClientID1 { get; set; } //do not use

           public static string UserConfigData { get; set; }

            public int ClaimIDTest { get; set; }
    }
}