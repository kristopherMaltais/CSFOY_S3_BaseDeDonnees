using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BibliothequeEntite
{
    public class Article
    {
        public string Isbn { get; private set; }
        public string TypeArticle { get; private set; }
        public string Resume { get; private set; }
        public decimal PrixUnitaire { get; private set; }  
        public char IndicateurEnCommande { get; private set; }
        public int QuantiteEnCommande { get; private set; }
        public DateTime DateParution { get; private set; }
        public int MaisonEditionId { get; private set; }
        public string Langue { get; private set; }

        public Article(string p_isbn, string p_typeArticle, string p_resume, decimal p_prixUnitaire, char p_indicateurEnCommande, int p_quantiteEnCommande, DateTime p_dateParution, int p_maisonEditionId, string p_langue)
        {
            // Preconditions
            if(p_isbn == null)
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
        public override string ToString()
        {
            return this.TypeArticle;
        }
    }
}
