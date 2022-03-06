using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BibliothequeEntite
{
    public class EmpruntCourt
    {
        public string TitreArticle { get; private set; }
        public int NbLocations { get; private set; }

        public EmpruntCourt(string p_titreArticle, int p_nbLocations)
        {
            this.TitreArticle = p_titreArticle;
            this.NbLocations = p_nbLocations;
        }
        public override string ToString()
        {
            return $"{this.TitreArticle} : {this.NbLocations}x";
        }
    }
}
