using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BibliothequeEntite;
using Microsoft.EntityFrameworkCore;

namespace BibliothequeDAL
{
    public class DepotEmprunt : IDepotEmprunt
    {
        private ApplicationDBContext m_dbContext;
        public DepotEmprunt(ApplicationDBContext p_dbContext)
        {
            if (p_dbContext is null)
            {
                throw new ArgumentNullException(nameof(p_dbContext));
            }

            this.m_dbContext = p_dbContext;
        }
        public List<EmpruntCourt> ListerEmpruntsPourMoisEtAnnee(string p_annee, string p_mois)
        {
            return this.m_dbContext.ListerEmpruntsPourMoisEtAnnee(p_annee, p_mois).Select(e => e.VersEntite()).ToList();
        }
        public List<VerificateurInsertionEmprunt> VerifierSiInsertionEmpruntValide(string p_isbn, int p_numMembre)
        {
            List<VerificateurInsertionEmpruntDTO> verificateursDTO = this.m_dbContext.VerifierSiInsertionEmpruntValide(p_isbn, p_numMembre);
            List<VerificateurInsertionEmprunt> verificateur = new List<VerificateurInsertionEmprunt>();
            foreach(VerificateurInsertionEmpruntDTO verificateurDTO in verificateursDTO)
            {
                verificateur.Add(verificateurDTO.VersEntite());
            }

            return verificateur;
        }
        public void AjouterEmprunt(Emprunt p_empruntAAjouter)
        {
            EmpruntDTO nouvelEmprunt = new EmpruntDTO(p_empruntAAjouter);
            this.m_dbContext.Add(nouvelEmprunt);
            this.m_dbContext.SaveChanges();
            this.m_dbContext.ChangeTracker.Clear();
        }
    }
}
