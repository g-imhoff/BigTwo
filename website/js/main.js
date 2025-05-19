// Smooth scrolling for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        
        document.querySelector(this.getAttribute('href')).scrollIntoConstrainedView({
            behavior: 'smooth'
        });
    });
});

// Add 'scrolled' class to navbar on scroll
window.addEventListener('scroll', function() {
    const navbar = document.querySelector('.navbar');
    if (window.scrollY > 50) {
        navbar.classList.add('scrolled');
    } else {
        navbar.classList.remove('scrolled');
    }
});

// Animation for download buttons
document.querySelectorAll('.btn-download').forEach(button => {
    button.addEventListener('mouseenter', function() {
        this.innerHTML = `<i class="fas fa-download me-2"></i>Download Now`;
    });
    
    button.addEventListener('mouseleave', function() {
        const platform = this.closest('.download-option').querySelector('h3').innerText;
        let extension = 'EXE';
        
        if (platform === 'Android') extension = 'APK';
        else if (platform === 'macOS') extension = 'DMG';
        else if (platform === 'Linux') extension = 'TAR';
        
        this.innerHTML = `<i class="fas fa-download me-2"></i>Download ${extension}`;
    });
});

// Fallback for Element.scrollIntoConstrainedView if not supported
if (!Element.prototype.scrollIntoConstrainedView) {
    Element.prototype.scrollIntoConstrainedView = function(options) {
        this.scrollIntoView(options);
    };
}
