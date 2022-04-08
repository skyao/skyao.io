module github.com/wowchemy/starter-academic/exampleSite

go 1.15

require (
	github.com/wowchemy/wowchemy-hugo-modules/wowchemy-cms/v5 v5.0.0-20220303211751-d75dbe7f3d22 // indirect
	github.com/wowchemy/wowchemy-hugo-modules/wowchemy/v5 v5.0.0-20220303211751-d75dbe7f3d22 // indirect
)

// replace with my forked repo for site https://skyao.io
//replace github.com/wowchemy/wowchemy-hugo-modules/v5 => github.com/skyao/hugo-academic/v5 skyao.io
//replace github.com/wowchemy/wowchemy-hugo-modules/wowchemy/v5  => github.com/skyao/hugo-academic/wowchemy/v5 skyao.io

// replace for develop when forked repo is in local
replace github.com/wowchemy/wowchemy-hugo-modules/v5 => ../hugo-academic

replace github.com/wowchemy/wowchemy-hugo-modules/wowchemy/v5 => ../hugo-academic/wowchemy
