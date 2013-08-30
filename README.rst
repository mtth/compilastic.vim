Compilastic.vim
===============

:code:`:make` for busy people.

.. code:: coffeescript

  hello = () ->
    'howdy'

  # make: --bare --output &%:h/js %


Features
--------

* Store global and file specific compiling options to avoid having to enter 
  them every time (in your .vimrc and in the corresponding file respectively).
* Compile your file silently using :code:`:Compile` so that you can stay 
  focused on the file being edited, no more distracting screen flickering.
* Execute and view the compiled output quickly using :code:`:Crun` and 
  :code:`:Cview` respectively.

:code:`:help Compilastic` for details and more.


Installation
------------

With `pathogen.vim`_:

.. code:: bash

  $ cd ~/.vim/bundle
  $ git clone https://github.com/mtth/locate.vim

Otherwise simply copy the folders into your ``.vim`` directory.


.. _`pathogen.vim`: https://github.com/tpope/vim-pathogen
