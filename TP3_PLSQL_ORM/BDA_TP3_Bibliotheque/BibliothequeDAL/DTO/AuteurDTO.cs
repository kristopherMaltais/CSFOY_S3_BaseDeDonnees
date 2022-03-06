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
    [Table("BI_AUTEURS")]
    public class AuteurDTO
    {
        [Key]
        [Column("AUTEURID")]
        public int AuteurId { get; set; }

        [Column("NOM")]
        public string Nom { get; set; }

        [Column("PRENOM")]
        public string Prenom { get; set; }

        [Column("PAYS")]
        public string Pays { get; set; }

        [Column("SITEINTERNET")]
        public string SiteInternet { get; set; }

        [Column("ANNEENAISSANCE")]
        public string AnneeNaissance { get; set; }

        [Column("ANNEEDECES")]
        public string AnneeDeces { get; set; }

        public AuteurDTO()
        {
            ;
        }
        public AuteurDTO(int p_auteurId, string p_nom, string p_prenom, string p_pays, string p_siteInternet, string p_anneeNaissance, string p_anneeDeces)
        {
            if (p_nom is null)
            {
                throw new ArgumentNullException(nameof(p_nom));
            }
            if (p_prenom is null)
            {
                throw new ArgumentNullException(nameof(p_prenom));
            }
            if (p_pays is null)
            {
                throw new ArgumentNullException(nameof(p_pays));
            }
            if (p_anneeNaissance is null)
            {
                throw new ArgumentNullException(nameof(p_anneeNaissance));
            }
            this.AuteurId = p_auteurId;
            this.Nom = p_nom;
            this.Prenom = p_prenom;
            this.Pays = p_pays;
            this.SiteInternet = p_siteInternet;
            this.AnneeNaissance = p_anneeNaissance;
            this.AnneeDeces = p_anneeDeces;
        }
        public Auteur VersEntite()
        {
            return new Auteur(this.AuteurId, this.Nom, this.Prenom, this.Pays, this.SiteInternet, this.AnneeNaissance, this.AnneeDeces);
        }
    }
}
