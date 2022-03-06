using Microsoft.EntityFrameworkCore;

namespace BibliothequeDAL
{
    public class ApplicationDBContext : DbContext
    {
        public ApplicationDBContext(DbContextOptions<ApplicationDBContext> dbContextOptions) : base(dbContextOptions)
        {
            ;
        }

        public DbSet<ArticleDTO> Articles { get; set; }
        public DbSet<AuteurDTO> Auteurs { get; set; }
        public DbSet<EmpruntCourtDTO> EmpruntsCourts { get; set; }
        public DbSet<EmpruntDTO> Emprunt { get; set; }
        public DbSet<VerificateurInsertionEmpruntDTO> VerificationInsertionEmprunt { get; set; }
        public List<EmpruntCourtDTO> ListerEmpruntsPourMoisEtAnnee(string p_annee, string p_mois)
        {
            return this.EmpruntsCourts.FromSqlRaw($"SELECT * FROM TABLE(Pkg_Tp3.FCT_07Best({p_annee},{p_mois}));").ToList();
        }
        public List<VerificateurInsertionEmpruntDTO> VerifierSiInsertionEmpruntValide(string p_isbn, int p_numMembre)
        {
            return this.VerificationInsertionEmprunt.FromSqlRaw($"SELECT * FROM TABLE(Pkg_Tp3.VerifierAvantInsertionEmprunt('{p_isbn}',{p_numMembre}));").ToList();
            //VerificateurInsertionEmpruntDTO test = this.VerificationInsertionEmprunt.FromSqlRaw($"SELECT * FROM TABLE(Pkg_Tp3.VerifierAvantInsertionEmprunt('{p_isbn}',{p_numMembre}));").First();
        }
    }
}