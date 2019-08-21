using DataLayer;
using System;
using System.Linq;
using System.Web.UI.WebControls;
using Newtonsoft.Json;

namespace Orgsys_2017.Orgsys_Forms
{
    public partial class Orgsys_Wiki : System.Web.UI.Page
    {
        //Declaring variables for the json objects to be accesed by javascript
        protected string jsonCategoriesDis;//json for distinct categories
        protected string jsonResult;
        //On page load it selects all the questions, answers,etc from the Wiki table and converts it to json
        protected void Page_Load(object sender, EventArgs e)
        {
            OrgSys2017DataContext con = new OrgSys2017DataContext();

            var categoriesDis = con.Wikis.Select(x => x.category).Distinct().ToList();//selects distinct categories
            
            //Converts list to JSON
            jsonCategoriesDis = JsonConvert.SerializeObject(categoriesDis);
            jsonResult = JsonConvert.SerializeObject(con.Wikis);//converts whole table to json objects
        }
    }
}

//var questions = con.Wikis.Select(x => x.question).ToList();//Selects everything from the question column   
//var answers = con.Wikis.Select(x => x.answer).ToList();//selects everything from the answer column
//var categories = con.Wikis.Select(x => x.category).ToList();//selects category for all questions


//protected string jsonQuestions;
//protected string jsonAnswers;
//protected string jsonCategories;

//jsonQuestions = JsonConvert.SerializeObject(questions);
//jsonAnswers = JsonConvert.SerializeObject(answers);
//jsonCategories = JsonConvert.SerializeObject(categories);