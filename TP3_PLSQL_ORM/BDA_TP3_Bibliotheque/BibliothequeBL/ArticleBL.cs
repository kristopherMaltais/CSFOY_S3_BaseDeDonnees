using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BibliothequeEntite;

namespace BibliothequeBL
{
    public class ArticleBL
    {
        private IDepotArticle m_depotArticle;
        public ArticleBL(IDepotArticle p_depotArticle)
        {
            this.m_depotArticle = p_depotArticle;
        }

        public List<Article> ListerArticles()
        {
            return this.m_depotArticle.ListerArticles();
        }
    }
}
