using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace APILayer.Models.ExecutiveSummary
{
    public class ChartSeries<X, Y> : List<Tuple<X, Y>>
    {
        public string Name { get; set; }
    }

    public class ChartSeriesCollection<X, Y>
    {
        public List<string> Names => Series.Select(p => p.Name).ToList();
        public List<ChartSeries<X, Y>> Series { get; set; } = new List<ChartSeries<X, Y>>();
        public void Add(ChartSeries<X, Y> item) => Series.Add(item);
    }
}