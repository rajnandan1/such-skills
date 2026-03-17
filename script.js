(function(){
  'use strict';

  // -- Nav hide on scroll (with state guard) --
  var lastY=0;
  var navHidden=false;
  var nav=document.getElementById('nav');
  window.addEventListener('scroll',function(){
    var y=window.scrollY;
    var shouldHide=y>lastY&&y>80;
    if(shouldHide!==navHidden){
      navHidden=shouldHide;
      nav.classList.toggle('hidden',navHidden);
    }
    lastY=y;
  },{passive:true});

  // -- Reveal on scroll --
  var obs=new IntersectionObserver(function(entries){
    entries.forEach(function(e){
      if(e.isIntersecting){e.target.classList.add('visible');obs.unobserve(e.target);}
    });
  },{threshold:0.1,rootMargin:'0px 0px -40px 0px'});
  document.querySelectorAll('.reveal').forEach(function(el){obs.observe(el);});

  // -- Marquee (batched DOM insertion) --
  var platforms=[
    'YouTube Thumbnail','YouTube Banner','TikTok Video',
    'Instagram Post','Instagram Story','Instagram Reel',
    'Twitter/X Post','Twitter/X Header',
    'Facebook Cover','Facebook Post',
    'LinkedIn Banner','LinkedIn Post',
    'Pinterest Pin',
    'App Store Screenshot','Play Store Feature','Play Store Screenshot',
    'Substack Header','Threads Post','Dribbble Shot',
    'Bluesky Post','Product Hunt','Chrome Web Store',
    'Notion Cover','OG Image','Favicon'
  ];
  var marqueeEl=document.getElementById('marquee');
  var frag=document.createDocumentFragment();
  var doubled=platforms.concat(platforms);
  doubled.forEach(function(name){
    var chip=document.createElement('div');
    chip.className='platform-chip';
    chip.textContent=name;
    frag.appendChild(chip);
  });
  marqueeEl.appendChild(frag);

  // -- SVG icon helpers --
  function createSvg(stroke,strokeWidth){
    var svg=document.createElementNS('http://www.w3.org/2000/svg','svg');
    svg.setAttribute('width','16');
    svg.setAttribute('height','16');
    svg.setAttribute('fill','none');
    svg.setAttribute('stroke',stroke);
    svg.setAttribute('stroke-width',strokeWidth);
    svg.setAttribute('viewBox','0 0 24 24');
    svg.setAttribute('aria-hidden','true');
    return svg;
  }

  function createCopyIcon(){
    var svg=createSvg('currentColor','2');
    var rect=document.createElementNS('http://www.w3.org/2000/svg','rect');
    rect.setAttribute('x','9');rect.setAttribute('y','9');
    rect.setAttribute('width','13');rect.setAttribute('height','13');
    rect.setAttribute('rx','2');
    var path=document.createElementNS('http://www.w3.org/2000/svg','path');
    path.setAttribute('d','M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1');
    svg.appendChild(rect);svg.appendChild(path);
    return svg;
  }

  function createCheckIcon(){
    var svg=createSvg('#34d399','2.5');
    var path=document.createElementNS('http://www.w3.org/2000/svg','path');
    path.setAttribute('d','M20 6L9 17l-5-5');
    svg.appendChild(path);
    return svg;
  }

  // -- Copy toast --
  var toast=document.getElementById('copyToast');
  var toastTimer=null;
  function showToast(){
    if(toastTimer)clearTimeout(toastTimer);
    toast.classList.add('show');
    toastTimer=setTimeout(function(){toast.classList.remove('show');},1800);
  }

  function handleCopy(cmdEl){
    var text=cmdEl.querySelector('.cmd-text').textContent;
    var btn=cmdEl.querySelector('.copy-indicator');
    navigator.clipboard.writeText(text).then(function(){
      btn.replaceChildren(createCheckIcon());
      setTimeout(function(){btn.replaceChildren(createCopyIcon());},2000);
      cmdEl.classList.add('copied');
      setTimeout(function(){cmdEl.classList.remove('copied');},600);
      showToast();
    }).catch(function(){
      // Fallback: select text for manual copy
      var range=document.createRange();
      range.selectNodeContents(cmdEl.querySelector('.cmd-text'));
      var sel=window.getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
    });
  }

  // -- Setup all copy buttons (inject icons from JS) --
  document.querySelectorAll('.install-cmd').forEach(function(cmdEl){
    var indicator=cmdEl.querySelector('.copy-indicator');
    if(indicator)indicator.replaceChildren(createCopyIcon());
    cmdEl.addEventListener('click',function(){handleCopy(cmdEl);});
    cmdEl.addEventListener('keydown',function(e){
      if(e.key==='Enter'||e.key===' '){
        e.preventDefault();
        handleCopy(cmdEl);
      }
    });
  });

  // -- Stat counter animation --
  var reducedMotion=window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var statNums=document.querySelectorAll('.stat-num');
  if(statNums.length&&!reducedMotion){
    var statObs=new IntersectionObserver(function(entries){
      if(entries[0].isIntersecting){
        statObs.disconnect();
        statNums.forEach(function(el,i){
          var raw=el.textContent.trim();
          var suffix=raw.replace(/[0-9]/g,'');
          var target=parseInt(raw,10);
          if(isNaN(target))return;
          var duration=800;
          var delay=i*120;
          setTimeout(function(){
            var t0=performance.now();
            function tick(now){
              var p=Math.min((now-t0)/duration,1);
              var ep=1-Math.pow(1-p,4);
              el.textContent=Math.round(target*ep)+suffix;
              if(p<1)requestAnimationFrame(tick);
            }
            requestAnimationFrame(tick);
          },delay);
        });
      }
    },{threshold:0.5});
    statObs.observe(document.querySelector('.hero-stats'));
  }

  // -- Console easter egg --
  console.log(
    '%c// such-skills %c\n'+
    'Plugins for Claude Code.\n'+
    'https://github.com/rajnandan1/such-skills\n\n'+
    'Built by Raj Nandan Sharma',
    'color:#d4af78;font-size:16px;font-weight:bold;font-family:monospace',
    'color:#8e8ea3;font-size:12px;font-family:monospace'
  );

})();
