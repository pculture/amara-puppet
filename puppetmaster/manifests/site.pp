import "nodes"
stage { 'pre': before => Stage['main'] }
stage { 'post': require => Stage['main'] }
