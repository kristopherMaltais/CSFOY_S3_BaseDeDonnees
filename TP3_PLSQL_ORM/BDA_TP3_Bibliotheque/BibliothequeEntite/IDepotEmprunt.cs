using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BibliothequeEntite
{
    public interface IDepotEmprunt
    {
        public List<EmpruntCourt> ListerEmpruntsPourMoisEtAnnee(string p_annee, string p_mois);
        public List<VerificateurInsertionEmprunt> VerifierSiInsertionEmpruntValide(string p_isbn, int p_numMembre);
        public void AjouterEmprunt(Emprunt p_empruntAAjouter);
    }
}
