#!/usr/bin/env python
"""
Takes a list of bibcodes and gets the ADS data in a latex list of items and writes it out to a file.

You can get all your bibcodes by going to this URL (replacing 'Birnstiel,+T.'
with your name and initial):

	http://adsabs.harvard.edu/cgi-bin/nph-abs_connect?author=Birnstiel,+T.&jou_pick=NO&data_type=Custom&sort=NDATE&format=%5C%25R
	
select those bibcodes you want and copy them into the array below.
"""
LASTNAME='Birnstiel'
bibcodes = [
	'2014ApJ...780..153B',
	'2013Sci...340.1199V',
	'2013A&A...550L...8B',
	'2012A&A...545A..81P',
	'2012A&A...544L..16W',
	'2012A&A...540A..73W',
	'2012A&A...539A.148B',
	'2012A&A...538A.114P',
	'2010A&A...516L..14B',
	'2010A&A...513A..79B',
	'2009A&A...503L...5B']
import urllib2
FILE = 'pub_list.tex'
format = '\\\\item %\\13M: \\\\textit{%\\t}, %\\j (%\\Y) vol. %\\V, %\\p%-\\P\\.'
bib_split = '\r\n'
URL  = r'http://adsabs.harvard.edu/cgi-bin/nph-abs_connect?db_key=ALL&warnings=YES&version=1&bibcode=%s&nr_to_return=1000&start_nr=1&data_type=Custom&sort=NDATE&format=%s'%(urllib2.quote(bib_split.join(bibcodes)),urllib2.quote(format))
#
# get the data
#
response = urllib2.urlopen(URL)
html = response.read()
response.close()
#
# split in lines
#
html = html.split('\n')
#
# cut the header
#
while '\item' not in html[0]: del html[0]
while '' in html: html.remove('')
pubs = []
pub  = []
for j,i in enumerate(html):
    if '\\item' in i:
		#
		# when a new publication starts
		#
        pubs+= [pub]
        pub  = [i]
    else:
		#
		# else: keep adding the line
		#
        pub += [i]
#
#
#
#
# remove empty entries
#
while [] in pubs: pubs.remove([])
#
# write results
#
f = open(FILE,'w')
# write header if necessary
#f.write(r'\begin{supertabular}{p{\textwidth}}'+'\n')
for pub in pubs:
    line = ''.join(pub)
    line = line.replace('&','\&')
    line = line.replace(LASTNAME,'\\textbf{'+LASTNAME+'}')
    # write line ending if necessary
    #ending = '\\\\[-0.2cm] \n'
    ending = '\n'
    if 'Thesis' in line: line=line.replace(' vol.  ','')
    f.write(line+ending)
# write fooder if necessary
#f.write(r'\end{supertabular}')
f.close()
