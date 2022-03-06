// See https://aka.ms/new-console-template for more information
using BibliothequeBL;
using BibliothequeDAL;
using BibliothequeEntite;



int choixUtilisateur = 0;
do
{
    AfficherMenu();
    Console.WriteLine("Que voulez vous faire: ");
    choixUtilisateur = Convert.ToInt32(Console.ReadLine());
    switch (choixUtilisateur)
    {
        case 1:
            AfficherArticles();
            break;
        case 2:
            EmpruntsPourMoisEtAnnee("2021", "09");
            break;
        case 3: // Pour tester validation isbn, nomembre et article disponible changer les informations ici.
            bool aEteAjoute = EmprunterLivre("978-2-12345-012-1", 3);
            if (aEteAjoute)
            {
                Console.WriteLine("Livre a bien ete emprunte");
            }
            else
            {
                Console.WriteLine("Impossible d'emprunter ce livre");
            }
            break;
        default:
            break;
    }
} while (choixUtilisateur != 4);





static void AfficherArticles()
{
    List<Article> articles = new List<Article>();

    using (ApplicationDBContext dbContext = DALDbContextGeneration.ObtenirApplicationDBContext())
    {
        DepotArticle depotArticle = new DepotArticle(dbContext);
        ArticleBL articleBL = new ArticleBL(depotArticle);
        articles = articleBL.ListerArticles();
        Console.WriteLine("Types d'articles");
        articles?.ForEach(a => Console.WriteLine(a));
    }  
}

static void EmpruntsPourMoisEtAnnee(string p_annee, string p_mois)
{
    List<EmpruntCourt> emprunts = new List<EmpruntCourt>();

    using (ApplicationDBContext dbContext = DALDbContextGeneration.ObtenirApplicationDBContext())
    {
        DepotEmprunt depotEmprunts = new DepotEmprunt(dbContext);
        EmpruntBL empruntBL = new EmpruntBL(depotEmprunts);
        emprunts = empruntBL.ListerEmpruntsPourMoisEtAnnee(p_annee, p_mois);
        Console.WriteLine("Emprunts");
        emprunts?.ForEach(e => Console.WriteLine(e));
    }
}

static bool EmprunterLivre(string p_isbn, int p_numMembre)
{
    bool aEteAjoute;
    using (ApplicationDBContext dbContext = DALDbContextGeneration.ObtenirApplicationDBContext())
    {
        DepotEmprunt depotEmprunts = new DepotEmprunt(dbContext);
        EmpruntBL empruntBL = new EmpruntBL(depotEmprunts);
        aEteAjoute = empruntBL.AjouterEmprunt(p_isbn, p_numMembre);
    }

    return aEteAjoute;
}

static void AfficherMenu()
{
    Console.WriteLine("[1] Afficher Article et auteur");
    Console.WriteLine("[2] Afficher emprunts dernier mois en ordre du plus populaire");
    Console.WriteLine("[3] Emprunter un livre");
    Console.WriteLine("[4] Quitter");
}