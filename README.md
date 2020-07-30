# Comment publier un site sur GitHub

## Localisation du code source
Il y a différentes façons de publier un site sur GitHub. Les suivantes concernent
la création d'un site pour un projet GitHub existant :
- dossier *docs/* contenant le code source du site. Ce dossier doit se trouver
à la racine de la branche master
- branche *gh-pages* dans laquelle se trouve un fichier *index.html* (ou *index.md*...).

Les solutions précédentes permettent d'avoir accès aux ressources qui se trouvent
dans la même branche que le code source du site.

## Publier le site
La publication du site se fait à partir de la page GitHub du dépôt. Il faut cliquer
sur l'icône *Settings* se trouvant sur la barre d'outils sous le nom du dépôt. Une
fois dans *Settings*, il faut se rendre dans la section *GitHub Pages* et choisir
la source choisie pour le site. Cette source étant soit *gh-pages branch* soit
*master/docs folder* (il est aussi possible de choisir la branche master pour source
mais cette option concerne plutôt la publication d'un site qui n'est pas relié à un
projet existant). Une fois que la source est choisie, le site est publié par défaut
sur le domaine **username/github.io** et est publié en https. Il est possible
de le publier sur un autre domaine et ainsi de désactiver https si besoin. L'adresse
de publication de site est ensuite visible dans la section *GitHub Pages* de *Settings*.

Voir [GitHub Pages](https://docs.github.com/en/github/working-with-github-pages/about-github-pages) pour plus d'explications.
