EMACS = emacs
EMACSFLAGS =
GHC = ghc
GHCFLAGS = -Wall -Werror -O1
HLINT = hlint
HLINTFLAGS =
CASK = cask
PKGDIR := $(shell EMACS=$(EMACS) $(CASK) package-directory)

# Export the used EMACS to recipe environments
export EMACS

HS_BUILDDIR = build/hs
EL_SRCS = flycheck-haskell.el
EL_OBJS = $(EL_SRCS:.el=.elc)
HS_SRCS = get-cabal-configuration.hs
HS_OBJS = $(HS_SRCS:.hs=)
HELPER_SRCS = helpers/get-source-directories.hs
PACKAGE = flycheck-haskell-$(VERSION).tar

.PHONY: compile dist \
	lint test \
	clean clean-elc clean-dist clean-deps \
	deps

# Build targets
compile : $(EL_OBJS) $(HS_OBJS)

dist :
	$(CASK) package

# Test targets
lint :
	$(HLINT) $(HLINTFLAGS) $(HS_SRCS)

test :
	$(CASK) exec ert-runner

# Support targets
deps : $(PKGDIR)

# Cleanup targets
clean : clean-elc clean-hs clean-dist clean-deps

clean-elc :
	rm -rf $(EL_OBJS)

clean-hs:
	rm -rf $(HS_OBJS) $(HS_BUILDDIR)

clean-dist :
	rm -rf $(DISTDIR)

clean-deps :
	rm -rf $(PKGDIR)

# File targets
%.elc : %.el $(PKGDIR)
	$(CASK) exec $(EMACS) -Q --batch $(EMACSFLAGS) -f batch-byte-compile $<

%: %.hs
	$(GHC) $(GHCFLAGS) -outputdir $(HS_BUILDDIR) -o $@ $<

$(PKGDIR) : Cask
	$(CASK) install
	touch $(PKGDIR)
