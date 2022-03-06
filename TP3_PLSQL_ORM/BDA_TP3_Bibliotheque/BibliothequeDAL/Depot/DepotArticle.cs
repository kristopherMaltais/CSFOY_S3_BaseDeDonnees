using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BibliothequeEntite;

namespace BibliothequeDAL
{
    public class DepotArticle : IDepotArticle
    {
        private ApplicationDBContext m_dbContext;

        public DepotArticle(ApplicationDBContext p_dbContext)
        {
            if (p_dbContext is null)
            {
                throw new ArgumentNullException(nameof(p_dbContext));
            }

            this.m_dbContext = p_dbContext;
        }

        public List<Article> ListerArticles()
        {
            return this.m_dbContext.Articles.Select(a => a.VersEntite()).ToList();
        }
    }
}
