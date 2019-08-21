using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DataLayer;
using System.Linq.Expressions;
using System.ComponentModel.DataAnnotations;
using System.Reflection;
using System.Data.Linq;
namespace BusinessLayer
{
    public abstract class BusinessObjectBase<T> : IBusinessObjectBase<T> where T : class
    {

        protected OrgSys2017DataContext Context;
        private bool Disposed = false;

        /// <summary>
        ///  /// Constructor 
        /// </summary>
        /// 
        protected BusinessObjectBase()
        {
            if (Context == null)
            { Context = new OrgSys2017DataContext(); }
        }

        /// <summary>
        /// Retrieves the filtered data of the table
        /// </summary>
        /// <param name="predicate"></param>
        /// <returns></returns>

        //A <Func T, bool> is a delegate that accepts a generic parameter T and returns a bool

        public List<T> GetTableData(Expression<Func<T, bool>> predicate)
        {

            return Context.GetTable<T>().Where(predicate).ToList(); 

        }

    

    /// <summary>
    /// Retrieves all the data of the table
    /// </summary>
    /// <returns></returns>

    public List<T> GetAll()
    {
            return Context.GetTable<T>().ToList();
    }
    /// <summary>
    /// 
    /// </summary>
    /// <param name="table"></param>
    public void SaveTableData(T tableRow)
    {
        Context.GetTable<T>().InsertOnSubmit(tableRow);

    }

    /// <summary>
    /// Save Changes to database
    /// </summary>
    public void SaveChanges()
    {
        Context.SubmitChanges();

    }


}
    }