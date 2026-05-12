// ========================
// 1. NAVBAR SCROLL EFFECT
// ========================
const navbar = document.getElementById('navbar');
const backToTop = document.getElementById('backToTop');

window.addEventListener('scroll', () => {
    const scrollY = window.scrollY;

    if (scrollY > 50) {
        navbar.classList.add('scrolled');
    } else {
        navbar.classList.remove('scrolled');
    }

    if (scrollY > 500) {
        backToTop.classList.add('show');
    } else {
        backToTop.classList.remove('show');
    }

    updateActiveNav();
});

backToTop.addEventListener('click', () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
});

// ========================
// 2. MOBILE MENU TOGGLE
// ========================
const mobileToggle = document.getElementById('mobileToggle');
const navLinks = document.getElementById('navLinks');

mobileToggle.addEventListener('click', () => {
    mobileToggle.classList.toggle('active');
    navLinks.classList.toggle('open');
});

navLinks.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
        mobileToggle.classList.remove('active');
        navLinks.classList.remove('open');
    });
});

// ========================
// 3. ACTIVE NAV LINK ON SCROLL
// ========================
function updateActiveNav() {
    const sections = document.querySelectorAll('section[id]');
    const scrollPos = window.scrollY + 150;

    sections.forEach(section => {
        const top = section.offsetTop;
        const height = section.offsetHeight;
        const id = section.getAttribute('id');
        const navLink = document.querySelector(`.nav-links a[href="#${id}"]`);

        if (navLink) {
            if (scrollPos >= top && scrollPos < top + height) {
                document.querySelectorAll('.nav-links a').forEach(a => a.classList.remove('active'));
                navLink.classList.add('active');
            }
        }
    });
}

// ========================
// 4. SCROLL REVEAL ANIMATIONS
// ========================
const revealElements = document.querySelectorAll('.reveal, .reveal-left, .reveal-right, .reveal-scale');

const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('visible');
        }
    });
}, {
    threshold: 0.15,
    rootMargin: '0px 0px -50px 0px'
});

revealElements.forEach(el => revealObserver.observe(el));

// ========================
// 5. COUNT-UP ANIMATION
// ========================
const counters = document.querySelectorAll('.count-up');
let countersAnimated = new Set();

const counterObserver = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting && !countersAnimated.has(entry.target)) {
            countersAnimated.add(entry.target);
            animateCounter(entry.target);
        }
    });
}, { threshold: 0.5 });

counters.forEach(counter => counterObserver.observe(counter));

function animateCounter(el) {
    const target = parseInt(el.getAttribute('data-target'));
    const duration = 2000;
    const startTime = performance.now();

    function update(currentTime) {
        const elapsed = currentTime - startTime;
        const progress = Math.min(elapsed / duration, 1);
        const eased = 1 - Math.pow(1 - progress, 3);
        const current = Math.floor(eased * target);
        el.textContent = current.toLocaleString();
        if (progress < 1) {
            requestAnimationFrame(update);
        } else {
            el.textContent = target.toLocaleString();
        }
    }

    requestAnimationFrame(update);
}

// ========================
// 6. SMOOTH SCROLL FOR NAV
// ========================
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({ behavior: 'smooth' });
        }
    });
});

// ========================
// 7. CONTACT FORM HANDLER — Formspree
// ========================
async function handleSubmit(e) {
    e.preventDefault();

    const form = document.getElementById('contactForm');
    const btn = document.getElementById('submitBtn');
    const success = document.getElementById('formSuccess');
    const error = document.getElementById('formError');

    const formId = form.querySelector('[name="_formspree_id"]').value.trim();

    if (!formId || formId === 'YOUR_FORM_ID') {
        error.querySelector('span').textContent =
            'Form ID not set yet. Follow the setup instructions inside the HTML file.';
        error.style.display = 'flex';
        return;
    }

    // Loading state
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Sending...';
    success.style.display = 'none';
    error.style.display = 'none';

    const data = new FormData(form);

    try {
        const res = await fetch(`https://formspree.io/f/${formId}`, {
            method: 'POST',
            body: data,
            headers: { 'Accept': 'application/json' }
        });

        if (res.ok) {
            success.style.display = 'flex';
            form.reset();
            btn.innerHTML = '<i class="fa-solid fa-check"></i> Sent!';
            btn.style.background = 'linear-gradient(135deg, #10b981, #059669)';

            setTimeout(() => {
                btn.innerHTML = 'Send Message &#10148;';
                btn.style.background = '';
                btn.disabled = false;
                success.style.display = 'none';
            }, 4000);
        } else {
            throw new Error('Server error');
        }
    } catch (err) {
        error.style.display = 'flex';
        btn.innerHTML = 'Send Message &#10148;';
        btn.style.background = '';
        btn.disabled = false;
    }
}

// ========================
// 8. PARALLAX ON MOUSE MOVE (Hero only)
// ========================
const hero = document.querySelector('.hero');
const profileFrame = document.querySelector('.profile-frame');

hero.addEventListener('mousemove', (e) => {
    const rect = hero.getBoundingClientRect();
    const x = (e.clientX - rect.left) / rect.width - 0.5;
    const y = (e.clientY - rect.top) / rect.height - 0.5;

    if (profileFrame) {
        profileFrame.style.transform = `perspective(1000px) rotateY(${x * 8}deg) rotateX(${-y * 8}deg)`;
    }
});

hero.addEventListener('mouseleave', () => {
    if (profileFrame) {
        profileFrame.style.transform = 'perspective(1000px) rotateY(0) rotateX(0)';
        profileFrame.style.transition = 'transform 0.5s ease';
    }
});

hero.addEventListener('mouseenter', () => {
    if (profileFrame) {
        profileFrame.style.transition = 'transform 0.1s ease';
    }
});

// ========================
// 9. TILT EFFECT ON RESOURCE CARDS
// ========================
document.querySelectorAll('.resource-card').forEach(card => {
    card.addEventListener('mousemove', (e) => {
        const rect = card.getBoundingClientRect();
        const x = (e.clientX - rect.left) / rect.width - 0.5;
        const y = (e.clientY - rect.top) / rect.height - 0.5;
        card.style.transform = `perspective(600px) rotateY(${x * 10}deg) rotateX(${-y * 10}deg) translateY(-8px)`;
    });

    card.addEventListener('mouseleave', () => {
        card.style.transform = '';
    });
});

// ========================
// 10. INITIAL LOAD
// ========================
window.addEventListener('load', () => {
    updateActiveNav();
});
