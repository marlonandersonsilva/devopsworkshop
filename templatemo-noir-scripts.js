// JavaScript Document

/*

TemplateMo 599 Noir Fashion

https://templatemo.com/tm-599-noir-fashion

*/

import { createClient } from '@supabase/supabase-js'
const SUPABASE_URL = import.meta?.env?.VITE_SUPABASE_URL
const SUPABASE_ANON_KEY = import.meta?.env?.VITE_SUPABASE_ANON_KEY
const supabase = SUPABASE_URL && SUPABASE_ANON_KEY ? createClient(SUPABASE_URL, SUPABASE_ANON_KEY) : null

 // Hero Carousel
        const slides = document.querySelectorAll('.carousel-slide');
        const indicators = document.querySelectorAll('.indicator');
        let currentSlide = 0;
        let slideInterval;

        function showSlide(index) {
            // Remove active class from all slides and indicators
            slides.forEach(slide => slide.classList.remove('active'));
            indicators.forEach(indicator => indicator.classList.remove('active'));
            
            // Add active class to current slide and indicator
            slides[index].classList.add('active');
            indicators[index].classList.add('active');
            
            currentSlide = index;
        }

        function nextSlide() {
            currentSlide = (currentSlide + 1) % slides.length;
            showSlide(currentSlide);
        }

        function startSlideShow() {
            slideInterval = setInterval(nextSlide, 4000); // Change slide every 4 seconds
        }

        function stopSlideShow() {
            clearInterval(slideInterval);
        }

        // Start automatic slideshow
        if (slides.length > 0) {
            startSlideShow();
            
            // Manual navigation via indicators
            indicators.forEach((indicator, index) => {
                indicator.addEventListener('click', () => {
                    stopSlideShow();
                    showSlide(index);
                    startSlideShow(); // Restart automatic slideshow
                });
            });

            // Pause on hover
            const carousel = document.querySelector('.hero-carousel');
            if (carousel) {
                carousel.addEventListener('mouseenter', stopSlideShow);
                carousel.addEventListener('mouseleave', startSlideShow);
            }
        }

        // Mobile menu toggle
        const menuToggle = document.getElementById('menuToggle');
        const mobileNav = document.getElementById('mobileNav');
        const mobileNavLinks = document.querySelectorAll('.mobile-nav-links a');

        menuToggle.addEventListener('click', () => {
            menuToggle.classList.toggle('active');
            mobileNav.classList.toggle('active');
        });

        mobileNavLinks.forEach(link => {
            link.addEventListener('click', () => {
                menuToggle.classList.remove('active');
                mobileNav.classList.remove('active');
            });
        });

        // Navbar scroll effect and scroll spy
        const navbar = document.getElementById('navbar');
        const sections = document.querySelectorAll('section[id]');
        const navLinks = document.querySelectorAll('.nav-link');

        function updateActiveNav() {
            const scrollY = window.pageYOffset;
            const navHeight = navbar.offsetHeight;
            
            // Navbar background on scroll
            if (scrollY > 100) {
                navbar.classList.add('scrolled');
            } else {
                navbar.classList.remove('scrolled');
            }
            
            // Scroll spy for active navigation
            sections.forEach(section => {
                const sectionHeight = section.offsetHeight;
                const sectionTop = section.offsetTop - navHeight - 10;
                const sectionId = section.getAttribute('id');
                
                if (scrollY >= sectionTop && scrollY < sectionTop + sectionHeight) {
                    navLinks.forEach(link => {
                        link.classList.remove('active');
                        if (link.getAttribute('href') === '#' + sectionId) {
                            link.classList.add('active');
                        }
                    });
                }
            });
            
            // Special case for home when at the very top
            if (scrollY < 100) {
                navLinks.forEach(link => {
                    link.classList.remove('active');
                    if (link.getAttribute('href') === '#home') {
                        link.classList.add('active');
                    }
                });
            }
        }

        window.addEventListener('scroll', updateActiveNav);
        window.addEventListener('resize', updateActiveNav); // Update on resize
        updateActiveNav(); // Call on load

        const tabButtons = document.querySelectorAll('.tab-btn');
        tabButtons.forEach(btn => {
            btn.addEventListener('click', () => {
                const category = btn.dataset.category;
                tabButtons.forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                const cards = document.querySelectorAll('.collection-card');
                cards.forEach(card => {
                    if (category === 'all' || card.dataset.category === category) {
                        card.style.display = 'block';
                        setTimeout(() => {
                            card.style.opacity = '1';
                            card.style.animation = 'fadeInUp 0.6s ease forwards';
                        }, 100);
                    } else {
                        card.style.opacity = '0';
                        setTimeout(() => {
                            card.style.display = 'none';
                        }, 300);
                    }
                });
            });
        });

        // Smooth scroll
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const targetId = this.getAttribute('href');
                const target = document.querySelector(targetId);
                
                if (target) {
                    // Get navbar height dynamically (it changes on medium screens)
                    const navHeight = navbar.offsetHeight;
                    let offsetTop;
                    
                    // If scrolling to home, go to top
                    if (targetId === '#home') {
                        offsetTop = 0;
                    } else {
                        // For all other sections, position them right at the top of viewport
                        // just below the navbar to completely hide previous content
                        offsetTop = target.offsetTop - navHeight;
                    }
                    
                    window.scrollTo({
                        top: offsetTop,
                        behavior: 'smooth'
                    });
                }
            });
        });

        // Parallax effect on scroll
        window.addEventListener('scroll', () => {
            const scrolled = window.pageYOffset;
            const parallax = document.querySelector('.hero-content');
            if (parallax) {
                parallax.style.transform = `translateY(${scrolled * 0.5}px)`;
            }
        });

        async function loadProducts() {
            const grid = document.getElementById('collectionsGrid');
            if (!grid) return;
            try {
                const resp = await fetch('/api/products?limit=24')
                const json = await resp.json()
                if (json?.success && Array.isArray(json.items)) {
                    const items = json.items.map(p => {
                        const imgUrl = p.imagem || 'images/urban-edge.avif';
                        const price = Number(p.preco).toLocaleString('en-US', { style: 'currency', currency: 'USD' });
                        const badge = p.categoria === 'limited' ? 'Limited' : 'New Arrival';
                        const subtitle = p.categoria === 'women' ? "Women's Collection" : p.categoria === 'men' ? "Men's Collection" : p.categoria === 'accessories' ? 'Accessories' : 'Exclusive Drop';
                        return `
                        <div class="collection-card" data-category="${p.categoria}">
                            <div class="collection-thumbnail">
                                <img src="${imgUrl}" alt="${p.nome}">
                            </div>
                            <div class="card-content">
                                <span class="card-badge">${badge}</span>
                                <h3 class="card-title">${p.nome}</h3>
                                <p class="card-subtitle">${subtitle}</p>
                                <p class="card-price">${price}</p>
                            </div>
                        </div>`
                    }).join('');
                    if (items) grid.innerHTML = items;
                    return;
                }
            } catch (e) {}
            if (!supabase) return;
            const { data, error } = await supabase
                .from('produtos')
                .select('id_produto,nome,preco,categoria,produto_imagens(url_imagem,principal)')
                .limit(24);
            if (error) return;
            const items = (data || []).map(p => {
                const imgs = Array.isArray(p.produto_imagens) ? p.produto_imagens : [];
                const principal = imgs.find(i => i.principal) || imgs[0];
                const imgUrl = principal?.url_imagem || 'images/urban-edge.avif';
                const price = Number(p.preco).toLocaleString('en-US', { style: 'currency', currency: 'USD' });
                const badge = p.categoria === 'limited' ? 'Limited' : 'New Arrival';
                const subtitle = p.categoria === 'women' ? "Women's Collection" : p.categoria === 'men' ? "Men's Collection" : p.categoria === 'accessories' ? 'Accessories' : 'Exclusive Drop';
                return `
                <div class="collection-card" data-category="${p.categoria}">
                    <div class="collection-thumbnail">
                        <img src="${imgUrl}" alt="${p.nome}">
                    </div>
                    <div class="card-content">
                        <span class="card-badge">${badge}</span>
                        <h3 class="card-title">${p.nome}</h3>
                        <p class="card-subtitle">${subtitle}</p>
                        <p class="card-price">${price}</p>
                    </div>
                </div>`
            }).join('');
            if (items) grid.innerHTML = items;
        }

        loadProducts();

        // Contact form handling
        const contactForm = document.getElementById('contactForm');
        if (contactForm) {
            contactForm.addEventListener('submit', (e) => {
                e.preventDefault();
                
                // Get form data
                const formData = new FormData(contactForm);
                const data = Object.fromEntries(formData);
                
                // Animate submit button
                const submitBtn = contactForm.querySelector('.form-submit');
                const originalText = submitBtn.textContent;
                submitBtn.textContent = 'Sending...';
                submitBtn.style.opacity = '0.7';
                submitBtn.disabled = true;
                
                // Simulate sending (replace with actual API call)
                setTimeout(() => {
                    submitBtn.textContent = 'Message Sent! ✓';
                    submitBtn.style.background = '#4CAF50';
                    
                    // Reset form
                    contactForm.reset();
                    
                    // Reset button after delay
                    setTimeout(() => {
                        submitBtn.textContent = originalText;
                        submitBtn.style.background = '';
                        submitBtn.style.opacity = '';
                        submitBtn.disabled = false;
                    }, 3000);
                }, 1500);
            });
        }

        // Form input animations
        const formInputs = document.querySelectorAll('.form-group input, .form-group textarea');
        formInputs.forEach(input => {
            input.addEventListener('focus', () => {
                input.parentElement.style.transform = 'translateY(-2px)';
            });
            input.addEventListener('blur', () => {
                input.parentElement.style.transform = '';
            });
        });

        // Intersection Observer for animations
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.animation = 'fadeInUp 0.8s ease forwards';
                    observer.unobserve(entry.target);
                }
            });
        }, observerOptions);

        document.querySelectorAll('.featured-container, .contact-content').forEach(el => {
            observer.observe(el);
        });

        const adminForm = document.getElementById('adminForm');
        const adminList = document.getElementById('adminList');
        let currentProductId = null;
        async function adminLoad() {
            if (!adminList) return;
            try {
                const resp = await fetch('/api/products?limit=100');
                const json = await resp.json();
                if (json?.success && Array.isArray(json.items)) {
                    adminList.innerHTML = json.items.map(p => {
                        const price = Number(p.preco).toLocaleString('en-US', { style: 'currency', currency: 'USD' });
                        const img = p.imagem || 'images/urban-edge.avif';
                        return `
                        <div class="collection-card" data-id="${p.id}">
                            <div class="collection-thumbnail">
                                <img src="${img}" alt="${p.nome}">
                            </div>
                            <div class="card-content">
                                <span class="card-badge">${p.categoria}</span>
                                <h3 class="card-title">${p.nome}</h3>
                                <p class="card-price">${price}</p>
                                <div class="cta-group">
                                    <button class="cta-button outline" data-action="edit" data-id="${p.id}">Editar</button>
                                    <button class="cta-button primary" data-action="delete" data-id="${p.id}">Excluir</button>
                                </div>
                            </div>
                        </div>`
                    }).join('');
                }
            } catch (e) {}
        }
        if (adminList) adminLoad();
        if (adminForm) {
            const nameEl = document.getElementById('adminName');
            const catEl = document.getElementById('adminCategory');
            const statusEl = document.getElementById('adminStatus');
            const priceEl = document.getElementById('adminPrice');
            const skuEl = document.getElementById('adminSKU');
            const descEl = document.getElementById('adminDescription');
            const saveBtn = document.getElementById('adminSaveBtn');
            const newBtn = document.getElementById('adminNewBtn');
            adminForm.addEventListener('submit', async (e) => {
                e.preventDefault();
                const body = {
                    nome: nameEl.value,
                    categoria: catEl.value,
                    status: statusEl.value,
                    preco: Number(priceEl.value),
                    sku: skuEl.value,
                    descricao: descEl.value || null,
                };
                try {
                    if (currentProductId) {
                        const r = await fetch(`/api/products/${currentProductId}`, { method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
                        await r.json();
                    } else {
                        const r = await fetch('/api/products', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
                        await r.json();
                    }
                    adminForm.reset();
                    currentProductId = null;
                    saveBtn.textContent = 'Salvar';
                    adminLoad();
                    loadProducts();
                } catch (e) {}
            });
            newBtn.addEventListener('click', () => {
                currentProductId = null;
                adminForm.reset();
                saveBtn.textContent = 'Salvar';
            });
        }
        if (adminList) {
            adminList.addEventListener('click', async (e) => {
                const t = e.target;
                if (!t || !t.closest) return;
                const btn = t.closest('button');
                if (!btn) return;
                const action = btn.dataset.action;
                const id = btn.dataset.id;
                if (action === 'edit') {
                    try {
                        const r = await fetch(`/api/products/${id}`);
                        const j = await r.json();
                        if (j?.success && j.item) {
                            currentProductId = j.item.id_produto || id;
                            document.getElementById('adminName').value = j.item.nome || '';
                            document.getElementById('adminCategory').value = j.item.categoria || 'women';
                            document.getElementById('adminStatus').value = j.item.status || 'ativo';
                            document.getElementById('adminPrice').value = j.item.preco || '';
                            document.getElementById('adminSKU').value = j.item.sku || '';
                            document.getElementById('adminDescription').value = j.item.descricao || '';
                            document.getElementById('adminSaveBtn').textContent = 'Atualizar';
                        }
                    } catch (e) {}
                }
                if (action === 'delete') {
                    try {
                        const r = await fetch(`/api/products/${id}`, { method: 'DELETE' });
                        await r.json();
                        adminLoad();
                        loadProducts();
                    } catch (e) {}
                }
            });
        }