using DataLayer;
using context = System.Web.HttpContext;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Windows.Forms;

namespace Orgsys_2017.Orgsys_Classes {
    public class ExceptionLogger {
       
    //Logs the exception if thrown into the database
    public static void LogException(Exception ex) {
        OrgSys2017DataContext con = new OrgSys2017DataContext();
            //Grabs UserID to reference who caused the error
            int ID = Convert.ToInt32(System.Web.HttpContext.Current.Session["UserID"]);
            int UserID = 0;
            if (ID != 0) {
               UserID = ID;
            } else {
                UserID = 0;
            }
            //Grab the URL page to find the error
            String exepurl = context.Current.Request.Url.ToString();
            //Create new error object
            Log err = new Log();
            err.UserID = UserID;
            err.Description = ex.Message.ToString();
            err.LogDateTime = DateTime.Now;
            err.BrowserURL = exepurl;
            err.Event = ex.GetType().Name.ToString();
            //add row to Logs database
            con.Logs.InsertOnSubmit(err);
            con.SubmitChanges();
        }
    }
}