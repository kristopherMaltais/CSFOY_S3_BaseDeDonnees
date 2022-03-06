using BibliothequeEntite;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BibliothequeDAL
{
    [Table("BI_EMPRUNTS")]
    public class EmpruntDTO
    {
        [Key]
        [Column("NOARTICLE")]
        public int NumeroArticle { get; set; }

        [Column("NOMEMBRE")]
        public int NumeroMembre { get; set; }

           
        public EmpruntDTO()
        {
            ;
        }
        public EmpruntDTO(Emprunt p_emprunt)
        {
            this.NumeroArticle = p_emprunt.NumeroArticle;
            this.NumeroMembre = p_emprunt.NumeroMembre;
        }
        public Emprunt VersEntite()
        {
            return new Emprunt(this.NumeroArticle, this.NumeroMembre);
        }
        
    }
}
