# --
# OTOBO is a web-based ticketing system for service organisations.
# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
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

package Kernel::System::MigrateFromOTRS::OTOBORebuildConfigCleanup;    ## no critic

use strict;
use warnings;

use parent qw(Kernel::System::MigrateFromOTRS::Base);

our @ObjectDependencies = (
    'Kernel::Language',
    'Kernel::System::Cache',
    'Kernel::System::DateTime',
);

=head2 CheckPreviousRequirement()

check for initial conditions for running this migration step.

Returns 1 on success

    my $Result = $DBUpdateTo6Object->CheckPreviousRequirement();

=cut

sub CheckPreviousRequirement {
    my ( $Self, %Param ) = @_;

        return 1;
}

=head1 NAME

Kernel::System::MigrateFromOTRS::OTOBORebuildConfigCleanup - Rebuilds the system configuration trying to cleanup the database.

=cut

sub Run {
    my ( $Self, %Param ) = @_;

    my %Result;
    
    # Set cache object with taskinfo and starttime to show current state in frontend
    my $CacheObject = $Kernel::OM->Get('Kernel::System::Cache');
    my $DateTimeObject = $Kernel::OM->Create( 'Kernel::System::DateTime');
    my $Epoch = $DateTimeObject->ToEpoch();

    $CacheObject->Set(
        Type  => 'OTRSMigration',
        Key   => 'MigrationState',
        Value => {
            Task        => 'OTOBORebuildConfigCleanup',
            SubTask     => "Rebuild the system configuration with --cleanup option.",
            StartTime   => $Epoch,
        },
    );

    $Self->RebuildConfig(
        %Param,
        CleanUpIfPossible => 1,
    );

    $Result{Message}    = $Self->{LanguageObject}->Translate( "OTOBO Config cleanup." );
    $Result{Comment}    = $Self->{LanguageObject}->Translate( "Completed." );
    $Result{Successful} = 1;

    return \%Result;
}

1;
