function changeLanguage(lang) {
    // Masquer tous les éléments de l'autre langue
    document.querySelectorAll('.lang-fr, .lang-en').forEach(el => {
        el.classList.add('hidden');
    });
    
    // Afficher tous les éléments de la langue sélectionnée
    document.querySelectorAll(`.lang-${lang}`).forEach(el => {
        el.classList.remove('hidden');
    });
    
    // Changer l'ordre d'affichage pour les titres
//  if (lang === 'fr') {
   //     document.querySelector('.logo-fr').classList.remove('hidden');
   //     document.querySelector('.logo-en').classList.add('hidden');
   // } else {
   //     document.querySelector('.logo-fr').classList.add('hidden');
  //      document.querySelector('.logo-en').classList.remove('hidden');
  //  }
}

// Initialiser en français par défaut
document.addEventListener('DOMContentLoaded', () => {
    changeLanguage('fr');
});