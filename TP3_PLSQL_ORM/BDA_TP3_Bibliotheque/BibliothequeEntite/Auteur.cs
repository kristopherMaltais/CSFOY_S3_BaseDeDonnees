namespace BibliothequeEntite
{
    public class Auteur
    {
        public int AuteurId { get; private set; }
        public string Nom { get; private set; }
        public string Prenom { get; private set; }
        public string Pays { get; private set; }
        public string SiteInternet { get; private set; }
        public string AnneeNaissance { get; private set; }
        public string AnneeDeces { get; private set; }

        public Auteur(int p_auteurId, string p_nom, string p_prenom, string p_pays, string p_siteInternet, string p_anneeNaissance, string p_anneeDeces)
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
    }
}