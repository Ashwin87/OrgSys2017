using DataLayer;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Net.Http;
using System.Reflection;
using System.Security.Cryptography;
using System.Text;
using System.Transactions;
using System.Web;
using System.Web.UI.HtmlControls;
using System.Web.Services;
using System.Web.Script.Services;
using Orgsys_2017.Orgsys_Classes;
using APILayer.Controllers;

/* Author: Marie Gougeon
* Created: 01-12-2017
* Updated: 08-30-2017
* Description: login controller for all api calls at login
*/

namespace Orgsys_2017.Orgsys_Forms{
    public partial class Orgsys_Login : OSI_Page {
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        //grab string from javascript, parse out the clientid and send it to OSI_Page.cs
        public static void setTokenSession(string token){
            try
            {
                HttpContext.Current.Session["token"] = token;
                //SessionController.updateUserSession(token);
            } catch (Exception ex){
                ExceptionLogger.LogException(ex);
            }
        }
       
    }
}    


