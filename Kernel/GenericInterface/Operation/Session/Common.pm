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


package Kernel::GenericInterface::Operation::Session::Common;

use strict;
use warnings;

use Kernel::System::VariableCheck qw(:all);

our $ObjectManagerDisabled = 1;

=head1 NAME

Kernel::GenericInterface::Operation::Session::Common - Base class for Session Operations

=head1 PUBLIC INTERFACE

=head2 CreateSessionID()

performs user authentication and return a new SessionID value

    my $SessionID = $CommonObject->CreateSessionID(
        Data {
            UserLogin         => 'Agent1',
            CustomerUserLogin => 'Customer1',       # optional, provide UserLogin or
                                                    #   CustomerUserLogin
            Password          => 'some password',   # plain text password
        }
    );

Returns undef on failure or

    $SessionID = 'AValidSessionIDValue';         # the new session id value

=cut

sub CreateSessionID {
    my ( $Self, %Param ) = @_;

    my $User;
    my %UserData;
    my $UserType;

    # get params
    my $PostPw = $Param{Data}->{Password} || '';

    if ( defined $Param{Data}->{UserLogin} && $Param{Data}->{UserLogin} ) {

        # if UserLogin
        my $PostUser = $Param{Data}->{UserLogin} || '';

        # check submitted data
        $User = $Kernel::OM->Get('Kernel::System::Auth')->Auth(
            User => $PostUser,
            Pw   => $PostPw,
        );
        %UserData = $Kernel::OM->Get('Kernel::System::User')->GetUserData(
            User  => $User,
            Valid => 1,
        );
        $UserType = 'User';
    }
    elsif ( defined $Param{Data}->{CustomerUserLogin} && $Param{Data}->{CustomerUserLogin} ) {

        # if UserCustomerLogin
        my $PostUser = $Param{Data}->{CustomerUserLogin} || '';

        # check submitted data
        $User = $Kernel::OM->Get('Kernel::System::CustomerAuth')->Auth(
            User => $PostUser,
            Pw   => $PostPw,
        );
        %UserData = $Kernel::OM->Get('Kernel::System::CustomerUser')->CustomerUserDataGet(
            User  => $PostUser,
            Valid => 1,
        );
        $UserType = 'Customer';
    }

    # login is invalid
    return if !$User;

    # create new session id
    my $NewSessionID = $Kernel::OM->Get('Kernel::System::AuthSession')->CreateSessionID(
        %UserData,
        UserLastRequest => $Kernel::OM->Create('Kernel::System::DateTime')->ToEpoch(),
        UserType        => $UserType,
        SessionSource   => 'GenericInterface',
    );

    return $NewSessionID if ($NewSessionID);

    return;
}

1;

=head1 TERMS AND CONDITIONS

This software is part of the OTOBO project (L<https://otobo.de/>).

This software comes with ABSOLUTELY NO WARRANTY. For details, see
the enclosed file COPYING for license information (GPL). If you
did not receive this file, see L<https://www.gnu.org/licenses/gpl-3.0.txt>.

=cut