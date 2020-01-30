# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2019 OTRS AG, https://otrs.com/
# Copyright (C) 2019-2020 Rother OSS GmbH, https://otobo.de/
# --
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
# --


use Kernel::System::Valid;

package Kernel::System::Valid;    ## no critic
use strict;
use warnings;

#
# This file demonstrates how to use the autoload mechanism of OTOBO to change existing functionality,
#   adding a method to Kernel::System::Valid in this case.
#

#
# Please note that all autoload files have to be registered via SysConfig (see AutoloadPerlPackages###1000-Test).
#

sub AutoloadTest {
    return 1;
}

1;