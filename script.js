(function(){
  'use strict';

  // -- Nav hide on scroll --
  var lastY=0;
  var nav=document.getElementById('nav');
  window.addEventListener('scroll',function(){
    var y=window.scrollY;
    nav.classList.toggle('hidden',y>lastY&&y>80);
    lastY=y;
  },{passive:true});

  // -- Reveal on scroll --
  var obs=new IntersectionObserver(function(entries){
    entries.forEach(function(e){
      if(e.isIntersecting){e.target.classList.add('visible');obs.unobserve(e.target);}
    });
  },{threshold:0.1,rootMargin:'0px 0px -40px 0px'});
  document.querySelectorAll('.reveal').forEach(function(el){obs.observe(el);});

  // -- Marquee (safe DOM creation) --
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
  var doubled=platforms.concat(platforms);
  doubled.forEach(function(name){
    var chip=document.createElement('div');
    chip.className='platform-chip';
    chip.textContent=name;
    marqueeEl.appendChild(chip);
  });

  // -- Copy command (safe DOM, keyboard accessible) --
  function createCopyIcon(){
    var svg=document.createElementNS('http://www.w3.org/2000/svg','svg');
    svg.setAttribute('width','16');
    svg.setAttribute('height','16');
    svg.setAttribute('fill','none');
    svg.setAttribute('stroke','currentColor');
    svg.setAttribute('stroke-width','2');
    svg.setAttribute('viewBox','0 0 24 24');
    svg.setAttribute('aria-hidden','true');
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
    var svg=document.createElementNS('http://www.w3.org/2000/svg','svg');
    svg.setAttribute('width','16');
    svg.setAttribute('height','16');
    svg.setAttribute('fill','none');
    svg.setAttribute('stroke','#34d399');
    svg.setAttribute('stroke-width','2.5');
    svg.setAttribute('viewBox','0 0 24 24');
    svg.setAttribute('aria-hidden','true');
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
    var btn=cmdEl.querySelector('.copy-btn');
    navigator.clipboard.writeText(text).then(function(){
      // Icon swap
      while(btn.firstChild)btn.removeChild(btn.firstChild);
      btn.appendChild(createCheckIcon());
      setTimeout(function(){
        while(btn.firstChild)btn.removeChild(btn.firstChild);
        btn.appendChild(createCopyIcon());
      },2000);
      // Green border flash
      cmdEl.classList.add('copied');
      setTimeout(function(){cmdEl.classList.remove('copied');},600);
      // Toast
      showToast();
    });
  }

  function setupCopyBtn(cmdEl){
    if(!cmdEl)return;
    cmdEl.addEventListener('click',function(){handleCopy(cmdEl);});
    cmdEl.addEventListener('keydown',function(e){
      if(e.key==='Enter'||e.key===' '){
        e.preventDefault();
        handleCopy(cmdEl);
      }
    });
  }

  setupCopyBtn(document.getElementById('cmd1'));
  setupCopyBtn(document.getElementById('cmd2'));
  setupCopyBtn(document.getElementById('cmd3'));
  setupCopyBtn(document.getElementById('cmd4'));
  setupCopyBtn(document.getElementById('cmd5'));
  setupCopyBtn(document.getElementById('cmd6'));
  setupCopyBtn(document.getElementById('cmd7'));
  setupCopyBtn(document.getElementById('cmd8'));

  // -- Stat counter animation --
  var reducedMotion=window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var statNums=document.querySelectorAll('.stat-num');
  if(statNums.length&&!reducedMotion){
    var statObs=new IntersectionObserver(function(entries){
      if(entries[0].isIntersecting){
        statObs.disconnect();
        statNums.forEach(function(el,i){
          var raw=el.textContent.trim();
          var suffix=raw.replace(/[0-9]/g,''); // e.g. "+"
          var target=parseInt(raw,10);
          if(isNaN(target))return;
          var start=0;
          var duration=800;
          var delay=i*120;
          setTimeout(function(){
            var t0=performance.now();
            function tick(now){
              var p=Math.min((now-t0)/duration,1);
              // ease-out-quart
              var ep=1-Math.pow(1-p,4);
              var val=Math.round(start+(target-start)*ep);
              el.textContent=val+suffix;
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
