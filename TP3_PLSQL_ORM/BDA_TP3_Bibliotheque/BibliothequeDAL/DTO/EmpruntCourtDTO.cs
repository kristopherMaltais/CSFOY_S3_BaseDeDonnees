using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BibliothequeEntite;

namespace BibliothequeDAL
{
    [Table("emprunts_q7")]
    public class EmpruntCourtDTO
    {
        [Key]
        [Column("titreArticle")]
        public string TitreArticle { get; set; }

        [Column("nombreEmprunt")]
        public int NbLocations { get; set; }
        public EmpruntCourtDTO()
        {
            ;
        }
        public EmpruntCourtDTO(string p_titreArticle, int p_nbLocations)
        {
            this.TitreArticle = p_titreArticle;
            this.NbLocations = p_nbLocations;
        }
        public EmpruntCourt VersEntite()
        {
            return new EmpruntCourt(this.TitreArticle, this.NbLocations);
        }
    }
}
