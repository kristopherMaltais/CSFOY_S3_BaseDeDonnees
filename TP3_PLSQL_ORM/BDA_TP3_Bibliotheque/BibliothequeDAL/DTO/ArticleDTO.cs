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
    [Table("BI_ARTICLES")]
    public class ArticleDTO
    {      
        [Key]
        [Column("ISBN")]
        public string Isbn { get; set; }

        [Column("TYPEARTICLE")]
        public string TypeArticle { get; set; }

        [Column("RESUME")]
        public string Resume { get; set; }

        [Column("PRIXUNITAIRE")]
        public decimal PrixUnitaire { get; set; }

        [Column("INDICATEURENCOMMANDE")]
        public char IndicateurEnCommande { get; set; }

        [Column("QUANTITEENCOMMANDE")]
        public int QuantiteEnCommande { get; set; }

        [Column("DATEPARUTION")]
        public DateTime DateParution { get; set; }

        [Column("MAISONEDITIONID")]
        public int MaisonEditionId { get; set; }

        [Column("LANGUE")]
        public string Langue { get; set; }

        public ArticleDTO()
        {
            ;
        }

        public ArticleDTO(string p_isbn, string p_typeArticle, string p_resume, decimal p_prixUnitaire, char p_indicateurEnCommande, int p_quantiteEnCommande, DateTime p_dateParution, int p_maisonEditionId, string p_langue)
        {
            // Preconditions
            if (p_isbn == null)
            {
                throw new ArgumentNullException(nameof(p_isbn));
            }
            if (p_typeArticle == null)
            {
                throw new ArgumentNullException(nameof(p_typeArticle));
            }
            if (p_resume == null)
            {
                throw new ArgumentNullException(nameof(p_resume));
            }
            if (p_prixUnitaire < 0)
            {
                throw new ArgumentOutOfRangeException(nameof(p_prixUnitaire));
            }
            if (p_quantiteEnCommande < 0)
            {
                throw new ArgumentOutOfRangeException(nameof(p_quantiteEnCommande));
            }
            if (p_maisonEditionId < 0)
            {
                throw new ArgumentOutOfRangeException(nameof(p_maisonEditionId));
            }
            if (p_langue == null)
            {
                throw new ArgumentNullException(nameof(p_langue));
            }


            this.Isbn = p_isbn;
            this.TypeArticle = p_typeArticle;
            this.Resume = p_resume;
            this.PrixUnitaire = p_prixUnitaire;
            this.IndicateurEnCommande = p_indicateurEnCommande;
            this.QuantiteEnCommande = p_quantiteEnCommande;
            this.DateParution = p_dateParution;
            this.MaisonEditionId = p_maisonEditionId;
            this.Langue = p_langue;
        }

        public Article VersEntite()
        {
            return new Article(this.Isbn, this.TypeArticle, this.Resume, this.PrixUnitaire, this.IndicateurEnCommande, this.QuantiteEnCommande, this.DateParution, this.MaisonEditionId, this.Langue);
        }
    }
}
