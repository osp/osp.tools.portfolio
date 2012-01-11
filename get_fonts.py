#!/usr/bin/env python

import feedparser
import html2text
import lxml.html
import re
import codecs
import subprocess

## {{{ http://code.activestate.com/recipes/577257/
_slugify_strip_re = re.compile(r'[^\w\s-]')
_slugify_hyphenate_re = re.compile(r'[-\s]+')
def slugify(value):
    """
    Normalizes string, converts to lowercase, removes non-alpha characters,
    and converts spaces to hyphens.
    
    From Django's "django/template/defaultfilters.py".
    """
    import unicodedata
    if not isinstance(value, unicode):
        value = unicode(value)
    value = unicodedata.normalize('NFKD', value).encode('ascii', 'ignore')
    value = unicode(_slugify_strip_re.sub('', value).strip().lower())
    return _slugify_hyphenate_re.sub('-', value)


d = feedparser.parse('http://ospublish.constantvzw.org/foundry/feed/')

f = open('foundry_image_list.txt','w')

for article in d.entries:
    a = article.title
    slug = slugify(article.id + '-' + a)
    with codecs.open(slug + '.mkd', 'w', 'utf-8') as g:
        g.write(a + '\n')
        g.write(len(a) * "=" + '\n\n')
        # we wrap it in a div for easy of parsing
        b = lxml.html.fragment_fromstring(article.content[0].value, "div")
        # we manipulate all the images:
        for img in b.cssselect('img'):
            href = img.attrib['src']
            # write absolute link to file for wgetting
            f.write(href + '\n')
            # set src attribute to relative file
            filename = href.split('/')[-1]
            img.attrib['src'] = filename
            # wrap img in p
            x = lxml.html.fragment_fromstring('<p></p>')
            x.append(img)
            # and put it in at the end of the div
            b.append(x)
    
        g.write(html2text.html2text(lxml.html.tostring(b)))
    
    pipe = subprocess.Popen('pandoc -f markdown -t context -o "%s.tex" "%s.mkd"' % (slug, slug), shell=True)
    pipe.wait()
    
    with codecs.open('%s.tex' % slug, 'a') as t:
        t.write('\n\n%% END OF %s\n\n' % slug)
    
