// ===============================
// Cloud Portfolio JavaScript
// ===============================

// Smooth Scrolling
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener("click", function (e) {
        e.preventDefault();

        const target = document.querySelector(this.getAttribute("href"));

        if (target) {
            target.scrollIntoView({
                behavior: "smooth",
                block: "start"
            });
        }
    });
});

// ===============================
// Fade Animation
// ===============================

const observer = new IntersectionObserver((entries) => {

    entries.forEach(entry => {

        if (entry.isIntersecting) {

            entry.target.classList.add("show");

        }

    });

}, {

    threshold: 0.15

});

document.querySelectorAll("section, .card, .step").forEach((el) => {

    el.classList.add("hidden");

    observer.observe(el);

});

// ===============================
// Active Navbar
// ===============================

const sections = document.querySelectorAll("section");

const navLinks = document.querySelectorAll(".nav-links a");

window.addEventListener("scroll", () => {

    let current = "";

    sections.forEach(section => {

        const sectionTop = section.offsetTop - 120;

        if (window.scrollY >= sectionTop) {

            current = section.getAttribute("id");

        }

    });

    navLinks.forEach(link => {

        link.classList.remove("active");

        if (link.getAttribute("href") === "#" + current) {

            link.classList.add("active");

        }

    });

});

// ===============================
// Navbar Shadow
// ===============================

const navbar = document.querySelector(".navbar");

window.addEventListener("scroll", () => {

    if (window.scrollY > 50) {

        navbar.style.boxShadow = "0 5px 20px rgba(0,0,0,0.5)";

    }

    else {

        navbar.style.boxShadow = "none";

    }

});

// ===============================
// Hero Button Animation
// ===============================

const heroButton = document.querySelector(".btn");

if (heroButton) {

    heroButton.addEventListener("mouseenter", () => {

        heroButton.style.transform = "scale(1.05)";

    });

    heroButton.addEventListener("mouseleave", () => {

        heroButton.style.transform = "scale(1)";

    });

}

// ===============================
// Card Hover Animation
// ===============================

const cards = document.querySelectorAll(".card");

cards.forEach(card => {

    card.addEventListener("mouseenter", () => {

        card.style.transform = "translateY(-10px)";

    });

    card.addEventListener("mouseleave", () => {

        card.style.transform = "translateY(0px)";

    });

});

// ===============================
// Footer Year
// ===============================

const footer = document.querySelector("footer p");

if (footer) {

    footer.innerHTML = footer.innerHTML.replace("2026", new Date().getFullYear());

}

// ===============================
// Console Message
// ===============================

console.log("========================================");
console.log(" Cloud Portfolio Loaded Successfully ");
console.log(" AWS | Terraform | GitHub Actions ");
console.log("========================================");