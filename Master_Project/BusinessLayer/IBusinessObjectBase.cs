using System.Linq.Expressions;
using System;
using System.Collections.Generic;
using System.Linq;

namespace BusinessLayer
{
    public interface IBusinessObjectBase<T> where T : class
    {
        /// <summary>
        /// Retrieves the filtered data of the table
        /// </summary>
        /// <param name="predicate"></param>
        /// <returns></returns>

        //A <Func T, bool> is a delegate that accepts a generic parameter T and returns a bool

        List<T> GetTableData(Expression<Func<T, bool>> predicate);

        /// <summary>
        /// Retrieves all the data of the table
        /// </summary>
        /// <returns></returns>

        List<T> GetAll();

        /// <summary>
        /// 
        /// </summary>
        /// <param name="table"></param>
        void SaveTableData(T table);

        // <summary>
        /// Save Changes to database
        /// </summary>
        void SaveChanges();

    }
}