using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BibliothequeEntite;
using Microsoft.EntityFrameworkCore;

namespace BibliothequeDAL
{
    [Table("tableauVerification")]
    [Keyless]
    public class VerificateurInsertionEmpruntDTO
    {
        [Column("estValide")]
        public int EstValide { get; set; }

        [Column("numArticle")]
        public int NumArticle { get; set; }
        public VerificateurInsertionEmpruntDTO()
        {
            ;
        }
        public VerificateurInsertionEmpruntDTO(int p_estValide, int p_numArticle)
        {
            if (p_estValide != 0 && p_estValide != 1)
            {
                throw new ArgumentOutOfRangeException(nameof(p_estValide));
            }

            this.EstValide = p_estValide;
            this.NumArticle = p_numArticle;
        }
        public VerificateurInsertionEmprunt VersEntite()
        {
            return new VerificateurInsertionEmprunt(this.EstValide, this.NumArticle);
        }
    }
}
