all:
	make html
	make pdf

install:
	poetry -vvv install

clean:
	cd book; rm -rf \
		*.aux *.out *.log pylabimshow* myplot* myfile* \
		combined_files hello.txt hello.py data.mat test.txt vectools.py \
		module1.py pylabhistogram.pdf eu-pop-2017.csv \
		_build .ipynb_checkpoints

html:
	poetry run jupyter-book build book --builder html

linkcheck:
	poetry run jupyter-book build book --builder linkcheck

pdf: book/*-*.ipynb
	poetry run jupyter-book build book --builder pdflatex

nbval:
	poetry run pytest -v --nbval book/*.ipynb --sanitize-with book/static/nbval_sanitize.cfg


docker-all:
	make docker-build
	make docker-html
	make docker-linkcheck
	make docker-pdf
	make docker-nbval

docker-build:
	docker build -t python4compscience .

# Occasionally (after changing branch) we need to force rebuild:
docker-build-nocache:
	docker build -t python4compscience2 --no-cache .

# Here we only bind the required directories and files into the docker container
# at runtime to avoid potential conflicts with local files
define DOCKER_RUN
docker run -u $(id -u ${USER}):$(id -g ${USER}) \
	-v $(CURDIR)/book:/io/book \
	-v $(CURDIR)/Makefile:/io/Makefile \
	-v $(CURDIR)/poetry.lock:/io/poetry.lock \
	-v $(CURDIR)/pyproject.toml:/io/pyproject.toml \
	python4compscience
endef

docker-html:
	$(DOCKER_RUN) make html

docker-html:
	$(DOCKER_RUN) make linkcheck

docker-pdf:
	$(DOCKER_RUN) make pdf

docker-nbval:
	$(DOCKER_RUN) make nbval

docker-clean:
	$(DOCKER_RUN) make clean

# to update the title page:
# - screenshot first page of pdf
# - (edit out date if desired)
# - add border around bitmap, for example using
#   "convert titlepage.png -shave 1x1 -bordercolor black -border 1 titlepage-with-border.png"
