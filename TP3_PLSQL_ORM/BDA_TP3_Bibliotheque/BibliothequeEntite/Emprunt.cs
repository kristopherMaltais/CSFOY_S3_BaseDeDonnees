using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BibliothequeEntite
{
    public class Emprunt
    {
        public int NumeroArticle { get; private set; }
        public int NumeroMembre { get; private set; }

        public Emprunt(int p_nuArticle, int p_nuMembre)
        {
            this.NumeroArticle = p_nuArticle;
            this.NumeroMembre = p_nuMembre;
        }
    }
}
