----
-- Copyright (C) 2022 by Fabian Mueller <fendrin@gmx.de>
-- SPDX-License-Identifier: GPL-2.0+

----
-- @file conf.lua
-- Executed by the lovr engine before all other files.
-- It is usually meant to overwrite the lovr.config callback
-- but we only setup Yuescript and continue from
-- client/conf.yue

local yue = require('yue')
local fs = lovr.filesystem
-- yue's use of io.open need to be replaced with lovr.filesystem ones.
-- This enables require to search the LÖVR savedir and fuse mode support.
yue.file_exist = fs.isFile
yue.read_file = function(fname)
   local contents, bytes = fs.read(fname)
   if contents == nil then
      return nil, 'File not found.'
   end
   return contents
end

yue.options.path = '?.yue'

yue('client.conf')
