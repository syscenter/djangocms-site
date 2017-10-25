all: install

SHELL := /bin/bash

PYTHON_MAJOR = 3.6
PYTHON_RELEASE = 3
PYTHON_VERSION = ${PYTHON_MAJOR}.${PYTHON_RELEASE}
PYTHON_URL = https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz

ROOT_DIR = $(shell pwd)
DOWNLOADS = ${ROOT_DIR}/downloads

PYTHON := ${ROOT_DIR}/bin/python${PYTHON_MAJOR}

${DOWNLOADS}:
	mkdir -p ${DOWNLOADS}

${DOWNLOADS}/Python-${PYTHON_VERSION}.tar.xz: ${DOWNLOADS}
	wget -O ${DOWNLOADS}/Python-${PYTHON_VERSION}.tar.xz ${PYTHON_URL}
	touch ${DOWNLOADS}/Python-${PYTHON_VERSION}.tar.xz

${DOWNLOADS}/Python-${PYTHON_VERSION}: ${DOWNLOADS}/Python-${PYTHON_VERSION}.tar.xz
	tar -C ${DOWNLOADS}/ -x -f ${DOWNLOADS}/Python-${PYTHON_VERSION}.tar.xz

${DOWNLOADS}/Python-${PYTHON_VERSION}/Makefile: ${DOWNLOADS}/Python-${PYTHON_VERSION}
	install -m 770 -d ${ROOT_DIR}/lib/Python-${PYTHON_VERSION}
	cd ${DOWNLOADS}/Python-${PYTHON_VERSION}/ && ${DOWNLOADS}/Python-${PYTHON_VERSION}/configure --prefix=${ROOT_DIR}/lib/Python-${PYTHON_VERSION}

${ROOT_DIR}/lib/Python-${PYTHON_VERSION}/bin/python${PYTHON_MAJOR}: ${DOWNLOADS}/Python-${PYTHON_VERSION}/Makefile
	make -C ${DOWNLOADS}/Python-${PYTHON_VERSION}
	make -C ${DOWNLOADS}/Python-${PYTHON_VERSION} install

${ROOT_DIR}/bin:
	mkdir -p ${ROOT_DIR}/bin

${ROOT_DIR}/bin/python${PYTHON_MAJOR}: ${ROOT_DIR}/lib/Python-${PYTHON_VERSION}/bin/python${PYTHON_MAJOR} ${ROOT_DIR}/bin
	ln -f -s ${ROOT_DIR}/lib/Python-${PYTHON_VERSION}/bin/python${PYTHON_MAJOR} ${ROOT_DIR}/bin/python${PYTHON_MAJOR}


${ROOT_DIR}/env/bin/djangocms:
	${ROOT_DIR}/env/bin/pip${PYTHON_MAJOR} install djangocms-installer


${ROOT_DIR}/env:
	${ROOT_DIR}/lib/Python-${PYTHON_VERSION}/bin/pip${PYTHON_MAJOR} install --upgrade -r ${ROOT_DIR}/requrements.deploy
	${ROOT_DIR}/lib/Python-${PYTHON_VERSION}/bin/virtualenv ${ROOT_DIR}/env
	source ${ROOT_DIR}/env/bin/activate &&	which pip

install: ${ROOT_DIR}/env
	${ROOT_DIR}/env/bin/djangocms syscenter -R > ${ROOT_DIR}/requrements.djangocms
	${ROOT_DIR}/env/bin/pip install -r ${ROOT_DIR}/requrements.djangocms
	${ROOT_DIR}/env/bin/pip install -r ${ROOT_DIR}/requrements.blog


syscenter: ${ROOT_DIR}/env/bin/djangocms
	${ROOT_DIR}/env/bin/djangocms --languages ru-RU,ru-UA,en --db sqlite://localhost/project.db syscenter
