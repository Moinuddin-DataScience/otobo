# --
# Copyright (C) 2001-2020 OTRS AG, https://otrs.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see https://www.gnu.org/licenses/gpl-3.0.txt.
# --

use strict;
use warnings;
use utf8;

use vars (qw($Self));

$Kernel::OM->ObjectParamAdd(
    'Kernel::System::UnitTest::Helper' => {
        RestoreDatabase => 1,
    },
);
my $Helper = $Kernel::OM->Get('Kernel::System::UnitTest::Helper');

my $TestUserLogin = $Helper->TestUserCreate(
    Groups => [ 'admin', 'users', ],
);
my $UserID = $Kernel::OM->Get('Kernel::System::User')->UserLookup(
    UserLogin => $TestUserLogin,
);

$Kernel::OM->ObjectParamAdd(
    'Kernel::Output::HTML::Notification::AgentOTOBOCommunity' => {
        UserID => $UserID,
    },
    'Kernel::Output::HTML::Notification::CustomerOTOBOCommunity' => {
        UserID => $UserID,
    },
);
my $AgentNotificationObject    = $Kernel::OM->Get('Kernel::Output::HTML::Notification::AgentOTOBOCommunity');
my $CustomerNotificationObject = $Kernel::OM->Get('Kernel::Output::HTML::Notification::CustomerOTOBOCommunity');
my $SystemDataObject           = $Kernel::OM->Get('Kernel::System::SystemData');

my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

my @Tests = (
    {
        Name                         => 'OB not installed',
        CurrentTime                  => '2016-09-30 12:00:00',
        OTOBOCommunityIsInstalled      => 0,
        SystemData                   => {},
        AgentNotificationResultAgent => '',
        AgentNotificationResultAdmin => '<!-- start Notify -->
<div class="MessageBox Info">
    <p>
            <a href="No-$ENV{"SCRIPT_NAME"}?Action=AdminOTOBOCommunity"> Upgrade to <b>OTOBO Community Edition</b>™ now! </a>
    </p>
</div>
<!-- end Notify -->
',
        CustomerNotificationResult => '',
    },
    {
        Name                    => 'OB installed, everything ok',
        CurrentTime             => '2016-09-30 12:00:00',
        OTOBOCommunityIsInstalled => 1,
        SystemData              => {
            'OTOBOCommunity::ExpiryDate'                       => '2016-10-30 12:00:00',
            'OTOBOCommunity::LastUpdateTime'                   => '2016-09-30 12:00:00',
            'OTOBOCommunity::BusinessPermission'               => '1',
            'OTOBOCommunity::FrameworkUpdateAvailable'         => '0',
            'OTOBOCommunity::LatestVersionForCurrentFramework' => '0.0.0',
            'Registration::State'                            => 'registered',
        },
        AgentNotificationResultAgent => '',
        AgentNotificationResultAdmin => '',
        CustomerNotificationResult   => '',
    },
    {
        Name                    => 'OB installed, expiry warning',
        CurrentTime             => '2016-09-30 12:00:00',
        OTOBOCommunityIsInstalled => 1,
        SystemData              => {
            'OTOBOCommunity::ExpiryDate'                       => '2016-10-10 12:00:00',
            'OTOBOCommunity::LastUpdateTime'                   => '2016-09-30 12:00:00',
            'OTOBOCommunity::BusinessPermission'               => '1',
            'OTOBOCommunity::FrameworkUpdateAvailable'         => '0',
            'OTOBOCommunity::LatestVersionForCurrentFramework' => '0.0.0',
            'Registration::State'                            => 'registered',
        },
        AgentNotificationResultAgent => '',
        AgentNotificationResultAdmin => '<!-- start Notify -->
<div class="MessageBox Notice">
    <p>
            The license for your <b>OTOBO Community Edition</b>™ is about to expire. Please make contact with sales@otrs.com to renew your contract!
    </p>
</div>
<!-- end Notify -->
',
        CustomerNotificationResult => '',
    },
    {
        Name                    => 'OB installed, LastUpdateTime outdated, show warning',
        CurrentTime             => '2016-09-30 12:00:00',
        OTOBOCommunityIsInstalled => 1,
        SystemData              => {
            'OTOBOCommunity::ExpiryDate'                       => '2016-10-30 12:00:00',
            'OTOBOCommunity::LastUpdateTime'                   => '2016-09-20 12:00:00',
            'OTOBOCommunity::BusinessPermission'               => '1',
            'OTOBOCommunity::FrameworkUpdateAvailable'         => '0',
            'OTOBOCommunity::LatestVersionForCurrentFramework' => '0.0.0',
            'Registration::State'                            => 'registered',
        },
        AgentNotificationResultAgent => '',
        AgentNotificationResultAdmin => '<!-- start Notify -->
<div class="MessageBox Error">
    <p>
            Connection to cloud.otrs.com via HTTPS couldn\'t be established. Please make sure that your OTOBO can connect to cloud.otrs.com via port 443.
    </p>
</div>
<!-- end Notify -->
',
        CustomerNotificationResult => '',
    },
    {
        Name                    => 'OB installed, LastUpdateTime outdated, show error',
        CurrentTime             => '2016-09-30 12:00:00',
        OTOBOCommunityIsInstalled => 1,
        SystemData              => {
            'OTOBOCommunity::ExpiryDate'                       => '2016-10-30 12:00:00',
            'OTOBOCommunity::LastUpdateTime'                   => '2016-09-10 12:00:00',
            'OTOBOCommunity::BusinessPermission'               => '1',
            'OTOBOCommunity::FrameworkUpdateAvailable'         => '0',
            'OTOBOCommunity::LatestVersionForCurrentFramework' => '0.0.0',
            'Registration::State'                            => 'registered',
        },
        AgentNotificationResultAgent => '<!-- start Notify -->
<div class="MessageBox Error">
    <p>
            This system uses the <b>OTOBO Community Edition</b>™ without a proper license! Please make contact with sales@otrs.com to renew or activate your contract!
    </p>
</div>
<!-- end Notify -->
',
        AgentNotificationResultAdmin => '<!-- start Notify -->
<div class="MessageBox Error">
    <p>
            This system uses the <b>OTOBO Community Edition</b>™ without a proper license! Please make contact with sales@otrs.com to renew or activate your contract!
    </p>
</div>
<!-- end Notify -->
',
        CustomerNotificationResult => '<!-- start Notify -->
<div class="MessageBox Error">
    <p>
            This system uses the <b>OTOBO Community Edition</b>™ without a proper license! Please make contact with sales@otrs.com to renew or activate your contract!
    </p>
</div>
<!-- end Notify -->
',
    },
    {
        Name                    => 'OB installed, LastUpdateTime outdated, block system',
        CurrentTime             => '2016-09-30 12:00:00',
        OTOBOCommunityIsInstalled => 1,
        SystemData              => {
            'OTOBOCommunity::ExpiryDate'                       => '2016-10-30 12:00:00',
            'OTOBOCommunity::LastUpdateTime'                   => '2016-09-01 12:00:00',
            'OTOBOCommunity::BusinessPermission'               => '1',
            'OTOBOCommunity::FrameworkUpdateAvailable'         => '0',
            'OTOBOCommunity::LatestVersionForCurrentFramework' => '0.0.0',
            'Registration::State'                            => 'registered',
        },
        AgentNotificationResultAgent => '<!-- start Notify -->
<div class="MessageBox Error">
    <p>
            This system uses the <b>OTOBO Community Edition</b>™ without a proper license! Please make contact with sales@otrs.com to renew or activate your contract!
<script>
if (!window.location.search.match(/^[?]Action=(AgentOTOBOCommunity|Admin.*)/)) {
    window.location.search = "Action=AgentOTOBOCommunity;Subaction=BlockScreen";
}
</script>
    </p>
</div>
<!-- end Notify -->
',
        AgentNotificationResultAdmin => '<!-- start Notify -->
<div class="MessageBox Error">
    <p>
            This system uses the <b>OTOBO Community Edition</b>™ without a proper license! Please make contact with sales@otrs.com to renew or activate your contract!
<script>
if (!window.location.search.match(/^[?]Action=(AgentOTOBOCommunity|Admin.*)/)) {
    window.location.search = "Action=AgentOTOBOCommunity;Subaction=BlockScreen";
}
</script>
    </p>
</div>
<!-- end Notify -->
',
        CustomerNotificationResult => '<!-- start Notify -->
<div class="MessageBox Error">
    <p>
            This system uses the <b>OTOBO Community Edition</b>™ without a proper license! Please make contact with sales@otrs.com to renew or activate your contract!
    </p>
</div>
<!-- end Notify -->
',
    },
);

for my $Test (@Tests) {

    my $DateTimeObject = $Kernel::OM->Create(
        'Kernel::System::DateTime',
        ObjectParams => {
            String => $Test->{CurrentTime},
        }
    );
    my $SystemTime = $DateTimeObject->ToEpoch();

    $Helper->FixedTimeSet($SystemTime);

    use Kernel::System::OTOBOCommunity;

    no warnings 'redefine';    ## no critic

    local *Kernel::System::OTOBOCommunity::OTOBOCommunityIsInstalled = sub {
        return $Test->{OTOBOCommunityIsInstalled};
    };

    for my $Key ( sort keys %{ $Test->{SystemData} } ) {
        $SystemDataObject->SystemDataDelete(
            Key    => $Key,
            UserID => 1,
        );
        $SystemDataObject->SystemDataAdd(
            Key    => $Key,
            Value  => $Test->{SystemData}->{$Key},
            UserID => 1,
        );
    }

    $Self->Is(
        scalar $AgentNotificationObject->Run(
            Type => 'Admin',
        ),
        $Test->{AgentNotificationResultAdmin},
        "$Test->{Name} - admin notification result",
    );

    my $OldPermissionCheck = \&Kernel::System::Group::PermissionCheck;

    # Pretend user is not a member of the admin group;
    use Kernel::System::Group;
    local *Kernel::System::Group::PermissionCheck = sub {
        my ( $Self, %Param ) = @_;
        if ( $Param{GroupName} eq 'admin' ) {
            return 0;
        }
        return $OldPermissionCheck->(@_);
    };

    $Self->Is(
        scalar $AgentNotificationObject->Run(
            Type => 'Agent',
        ),
        $Test->{AgentNotificationResultAgent},
        "$Test->{Name} - agent notification result",
    );

    $Self->Is(
        scalar $CustomerNotificationObject->Run(),
        $Test->{CustomerNotificationResult},
        "$Test->{Name} - customer notification result",
    );
}

# Cleanup is done by RestoreDatabase.

1;
