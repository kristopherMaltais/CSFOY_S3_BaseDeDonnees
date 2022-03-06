using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BibliothequeEntite;

namespace BibliothequeBL
{
    public class EmpruntBL
    {
        private IDepotEmprunt m_depotEmprunt;
        public EmpruntBL(IDepotEmprunt p_depotEmprunt)
        {
            this.m_depotEmprunt = p_depotEmprunt;
        }
        public List<EmpruntCourt> ListerEmpruntsPourMoisEtAnnee(string p_annee, string p_mois)
        {
            return this.m_depotEmprunt.ListerEmpruntsPourMoisEtAnnee(p_annee, p_mois);
        }
        public bool AjouterEmprunt(string p_isbn, int p_numMembre)
        {
            bool aEteAjoute = false;
            List<VerificateurInsertionEmprunt> verificationAvantInsertion =  this.m_depotEmprunt.VerifierSiInsertionEmpruntValide(p_isbn, p_numMembre);
            if(verificationAvantInsertion[0].EstValide == 1)
            {
                Emprunt nouvelEmprunt = new Emprunt(verificationAvantInsertion[0].NumArticle, p_numMembre);
                this.m_depotEmprunt.AjouterEmprunt(nouvelEmprunt);
                aEteAjoute = true;
            }

            return aEteAjoute;
        }
    }
}
