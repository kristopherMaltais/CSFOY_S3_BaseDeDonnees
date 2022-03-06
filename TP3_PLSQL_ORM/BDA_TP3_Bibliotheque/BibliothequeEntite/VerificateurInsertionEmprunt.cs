using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BibliothequeEntite
{
    public class VerificateurInsertionEmprunt
    {
        public int EstValide { get; private set; }
        public int NumArticle { get; private set; }
        public VerificateurInsertionEmprunt(int p_estValide, int p_numArticle)
        {
            if (p_estValide != 0 && p_estValide != 1)
            {
                throw new ArgumentOutOfRangeException(nameof(p_estValide));
            }

            this.EstValide = p_estValide;
            this.NumArticle = p_numArticle;
        }
    }
}
