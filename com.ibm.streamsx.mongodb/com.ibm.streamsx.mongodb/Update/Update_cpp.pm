# SPL_CGT_INCLUDE: ../Common/QueryCommon_cpp.cgt
# SPL_CGT_INCLUDE: ../Common/ThreadCommon_cpp.cgt
# SPL_CGT_INCLUDE: ../Common/MongoOperator_cpp.cgt

package Update_cpp;
use strict; use Cwd 'realpath';  use File::Basename;  use lib dirname(__FILE__);  use SPL::Operator::Instance::OperatorInstance; use SPL::Operator::Instance::Annotation; use SPL::Operator::Instance::Context; use SPL::Operator::Instance::Expression; use SPL::Operator::Instance::ExpressionTree; use SPL::Operator::Instance::ExpressionTreeEvaluator; use SPL::Operator::Instance::ExpressionTreeVisitor; use SPL::Operator::Instance::ExpressionTreeCppGenVisitor; use SPL::Operator::Instance::InputAttribute; use SPL::Operator::Instance::InputPort; use SPL::Operator::Instance::OutputAttribute; use SPL::Operator::Instance::OutputPort; use SPL::Operator::Instance::Parameter; use SPL::Operator::Instance::StateVariable; use SPL::Operator::Instance::TupleValue; use SPL::Operator::Instance::Window; 
sub main::generate($$) {
   my ($xml, $signature) = @_;  
   print "// $$signature\n";
   my $model = SPL::Operator::Instance::OperatorInstance->new($$xml);
   unshift @INC, dirname ($model->getContext()->getOperatorDirectory()) . "/../impl/nl/include";
   $SPL::CodeGenHelper::verboseMode = $model->getContext()->isVerboseModeOn();
   SPL::CodeGen::implementationPrologue($model);
   print "\n";
   print "\n";
   	use File::Basename qw(dirname);
   	
   	unshift @INC, dirname($model->getContext()->getOperatorDirectory()) . '/Common';
   	require BSONCommon;
   
   	my $authentication = ($_ = $model->getParameterByName('authentication')) ? $_->getValueAt(0) : undef;
   	my $username = ($_ = $model->getParameterByName('username')) ? $_->getValueAt(0)->getCppExpression() : undef;
   	my $password = ($_ = $model->getParameterByName('password')) ? $_->getValueAt(0)->getCppExpression() : undef;
   
   	unless ($authentication) {
   		if ($username && !$password) {
   			SPL::CodeGen::errorln("Password should be provided whithin username parameter", $model->getParameterByName('username')->getSourceLocation());
   		}
   		elsif (!$username && $password) {
   			SPL::CodeGen::errorln("Username should be provided whithin password parameter", $model->getParameterByName('password')->getSourceLocation());
   		}
   	}
   
   	my $dbHost = $model->getParameterByName('dbHost')->getValueAt(0)->getCppExpression();
   	my $dbPort = ($_ = $model->getParameterByName('dbPort')) ? $_->getValueAt(0)->getCppExpression() : 27017;
   	my $timeout = ($_ = $model->getParameterByName('timeout')) ? $_->getValueAt(0)->getCppExpression() : 0.0;
   	my $profiling = ($_ = $model->getParameterByName('profiling')) ? $_->getValueAt(0)->getSPLExpression() : 'off';
   	my $autoReconnect = ($_ = $model->getParameterByName('autoReconnect')) ? $_->getValueAt(0)->getCppExpression() : 'true';
   
   	my $findFieldsExpr = undef;
   	my $findQueryExpr = ($_ = $model->getParameterByName('findQuery')) ? $_->getValueAt(0) : undef;
   	SPL::CodeGen::errorln("The type '%s' of findQuery parameter is not a string, map or tuple.", $findQueryExpr->getSPLType(), $findQueryExpr->getSourceLocation())
   		if (defined $findQueryExpr && BSONCommon::keyLess($findQueryExpr->getSPLType()) && not SPL::CodeGen::Type::isString($findQueryExpr->getSPLType()));
   
   	my $metricName = "nUpdates";
   	my $myOpParams = 'findQueryBO_('.((defined $findQueryExpr && not $findQueryExpr->hasStreamAttributes()) ? 'buildFindQueryBO()' : 'BSONObj()').')';
   print "\n";
   print "\n";
   my $arg = '';
   my $iports = '';
   
   if ((defined $findFieldsExpr && $findFieldsExpr->hasStreamAttributes()) || (defined $findQueryExpr && $findQueryExpr->hasStreamAttributes())) {
   	$arg = 'Tuple const & tuple';
   	
   	for (my $i = 0; $i < $model->getNumberOfInputPorts(); $i++) {
   		$iports .= "IPort$i\Type const & $model->getInputPortAt($i)->getCppTupleName() = static_cast<IPort$i\Type const&>(tuple);\n" ;
   	}
   }
   
   if (defined $findFieldsExpr) {
   print "\n";
   print "\n";
   print '	BSONObj MY_OPERATOR_SCOPE::MY_OPERATOR::buildFindFieldsBO(';
   print $arg if($findFieldsExpr->hasStreamAttributes());
   print ') {', "\n";
   print '		';
   print $iports if($findFieldsExpr->hasStreamAttributes());
   print "\n";
   print "\n";
   print '		';
   BSONCommon::buildBSONObject($findFieldsExpr->getSourceLocation(), $findFieldsExpr->getCppExpression(), $findFieldsExpr->getSPLType(), 0);
   print "\n";
   print '		return b0.obj();', "\n";
   print '	}', "\n";
   }
   
   if (defined $findQueryExpr) {
   print "\n";
   print "\n";
   print '	BSONObj MY_OPERATOR_SCOPE::MY_OPERATOR::buildFindQueryBO(';
   print $arg if($findQueryExpr->hasStreamAttributes());
   print ') {', "\n";
   print '		';
   print $iports if($findQueryExpr->hasStreamAttributes());
   print "\n";
   print '		', "\n";
   print '		';
   if (SPL::CodeGen::Type::isString($findQueryExpr->getSPLType())) {
   print "\n";
   print '		 try {', "\n";
   print '			 return fromjson(';
   print $findQueryExpr->getCppExpression();
   print '.c_str());', "\n";
   print '		 }', "\n";
   print '		 catch(MsgAssertionException e) {', "\n";
   print '			 THROW(SPL::SPLRuntimeOperator, "FindQuery JSON string is not valid" << std::endl << e.what());', "\n";
   print '		 }', "\n";
   print '		';
   }
   		else {
   		 BSONCommon::buildBSONObject($findQueryExpr->getSourceLocation(), $findQueryExpr->getCppExpression(), $findQueryExpr->getSPLType(), 0);
   print "\n";
   print '		 return b0.obj();', "\n";
   print '		';
   }
   print "\n";
   print '	}', "\n";
   print "\n";
   }
   print "\n";
   print 'MY_OPERATOR_SCOPE::MY_OPERATOR::MY_OPERATOR() : ';
   print $metricName;
   print 'Metric_(getContext().getMetrics().getCustomMetricByName("';
   print $metricName;
   print '"))', "\n";
   print '							 ';
   print ((defined $myOpParams) ? ", $myOpParams" : '');
   print "\n";
   print '{', "\n";
   print "\n";
   print '	if(!MongoInit<void>::status_.isOK()) {', "\n";
   print '		THROW(SPL::SPLRuntimeOperator, "MongoDB initialization failed");', "\n";
   print '	}', "\n";
   print '}', "\n";
   print "\n";
   print 'MY_OPERATOR_SCOPE::MY_OPERATOR::~MY_OPERATOR() {}', "\n";
   print "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::allPortsReady() {', "\n";
   print '	', "\n";
   print '	try {', "\n";
   print '		DBClientConnection conn;', "\n";
   print '		conn.connect(buildConnUrl(';
   print $dbHost;
   print ', ';
   print $dbPort;
   print '));', "\n";
   print '	}', "\n";
   print '	catch( const DBException &e ) {', "\n";
   print '		if (';
   print $autoReconnect;
   print ')', "\n";
   print '			SPLAPPLOG(L_ERROR, e.what(), "MongoDB Connect");', "\n";
   print '		else', "\n";
   print '			THROW(SPL::SPLRuntimeOperator, e.what());', "\n";
   print '	}', "\n";
   print '}', "\n";
   print "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::prepareToShutdown() {', "\n";
   print '	client::shutdown();', "\n";
   print '}', "\n";
   print "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::process(Tuple const & tuple, uint32_t port) {', "\n";
   print '	';
   	my $numberOfInputPorts = $model->getNumberOfInputPorts();
   	for (my $i = 0; $i < $numberOfInputPorts; $i++) {
   print "\n";
   print '	  IPort';
   print $i;
   print 'Type const & ';
   print $model->getInputPortAt($i)->getCppTupleName();
   print ' = static_cast<IPort';
   print $i;
   print 'Type const&>(tuple);', "\n";
   print '	';
   }
   print "\n";
   print '	streams_boost::shared_ptr<OPort0Type> otuplePtr;', "\n";
   print '	bool errorFound = false;', "\n";
   print "\n";
   # [----- perl code -----]
   	foreach my $attribute (@{$model->getOutputPortAt(0)->getAttributes()}) {
   	  my $name = $attribute->getName();
   	  if ($attribute->hasAssignmentWithOutputFunction()) {
   		  my $operation = $attribute->getAssignmentOutputFunctionName();
   		  my $upsert = ($operation =~ /^Upsert/) ? 'true' : 'false';
   		  my $multi = ($operation =~ /Documents/) ? 'true' : 'false';
   		  my $isJson =  ($operation =~ /AsJson$/) ? 1 : 0;
   
   		  if ($operation eq 'AsIs') {
   			my $init = $attribute->getAssignmentOutputFunctionParameterValueAt(0)->getCppExpression();
   		  
   print "\n";
   print '			otuplePtr->set_';
   print $name;
   print '(';
   print $init;
   print ');', "\n";
   print '		  ';
   }
   		  else {
   			my $numberOfParams = @{$attribute->getAssignmentOutputFunctionParameterValues};
   			my $expr;
   			my $key = '';
   			my $keyAssigned = $numberOfParams > 3;
   			if ($keyAssigned) {
   				$key = $attribute->getAssignmentOutputFunctionParameterValueAt(2)->getCppExpression();
   				$expr = $attribute->getAssignmentOutputFunctionParameterValueAt(3);
   			}
   			else {
   				$expr = $attribute->getAssignmentOutputFunctionParameterValueAt(2);
   				if (!$isJson && BSONCommon::keyLess($expr->getSPLType())) {
   					SPL::CodeGen::errorln("The type '%s' of the expression '%s' requires additional key parameter.", $expr->getSPLType(), $expr->getSPLExpression(), $expr->getSourceLocation());
   				}
   			}
   			my $exprLocation = $expr->getSourceLocation();
   			my $cppExpr = $expr->getCppExpression();
   			my $splType = $expr->getSPLType();
   			
   			if ($numberOfInputPorts > 1 && $expr->hasStreamAttributes()) {
   				my $portNumber = -1;
   				for (my $i = 0; $i < $numberOfInputPorts; $i++) {
   					if (index($cppExpr, $model->getInputPortAt($i)->getCppTupleName()) != -1) {
   						if ($portNumber != -1) {
   							SPL::CodeGen::errorln("Multiple input ports attributes in expression '%s' are used.", $expr->getSPLExpression(), $expr->getSourceLocation());
   						}
   						else {
   							$portNumber = $i;
   						}
   					}
   				}
   print "\n";
   print '		if(port == ';
   print $portNumber;
   print ')', "\n";
   print '			';
   }
   print "\n";
   print '		{', "\n";
   print '		', "\n";
   # [----- perl code -----]
   			BSONCommon::buildBSONObjectWithKey($exprLocation, $key, $cppExpr, $splType, $isJson);
   			
   			my $db = $attribute->getAssignmentOutputFunctionParameterValueAt(0)->getCppExpression();
   			my $collection = $attribute->getAssignmentOutputFunctionParameterValueAt(1)->getCppExpression();
   # [----- perl code -----]
   print "\n";
   print '			', "\n";
   print '			';
   if (defined $findQueryExpr && $findQueryExpr->hasStreamAttributes()) {
   print "\n";
   print '				const BSONObj & findQueryBO = buildFindQueryBO(tuple);', "\n";
   print '			';
   }
   			else {
   print "\n";
   print '				const BSONObj & findQueryBO = findQueryBO_;', "\n";
   print '			';
   }
   print "\n";
   print '			', "\n";
   print '			DBClientConnection * connPtr = getDBClientConnection(';
   print $db;
   print ', ';
   print $dbHost;
   print ', ';
   print $dbPort;
   print ');', "\n";
   print '			', "\n";
   print '			if(connPtr->isFailed()) {', "\n";
   print '				if (';
   print $autoReconnect;
   print ') {', "\n";
   print '					SPLAPPLOG(L_ERROR, "Trying to reconnect to " << ';
   print $dbHost;
   print ' << ":" << ';
   print $dbPort;
   print ', "MongoDB Connect");', "\n";
   print '					connPtr->isStillConnected();', "\n";
   print '				}', "\n";
   print '				else {', "\n";
   print '					THROW(SPL::SPLRuntimeOperator, "Connection to " << ';
   print $dbHost;
   print ' << ":" << ';
   print $dbPort;
   print ' << " aborted");', "\n";
   print '				}', "\n";
   print '			}', "\n";
   print '				', "\n";
   print '			';
   if ($profiling eq 'slow') {
   print "\n";
   print '				connPtr->setDbProfilingLevel(';
   print $db;
   print ',  ProfileSlow);', "\n";
   print '			';
   } elsif ($profiling eq 'all') {
   print "\n";
   print '				connPtr->setDbProfilingLevel(';
   print $db;
   print ',  ProfileAll);', "\n";
   print '			';
   }
   print "\n";
   print '			', "\n";
   print '			';
   			
   print "\n";
   print '			connPtr->update(buildDbCollection(';
   print $db;
   print ', ';
   print $collection;
   print '), findQueryBO, bsonObj, ';
   print $upsert;
   print ', ';
   print $multi;
   print ');', "\n";
   print '			const string & errorMsg = connPtr->getLastError();', "\n";
   print '			', "\n";
   print '			if (errorMsg == "") {', "\n";
   print '				nUpdatesMetric_.incrementValue();', "\n";
   print '			}', "\n";
   print '			else {				', "\n";
   print '				errorFound = true;', "\n";
   print '				SPLAPPLOG(L_ERROR, errorMsg, "MongoDB Update");', "\n";
   print '				if(!otuplePtr){', "\n";
   print '					otuplePtr = streams_boost::shared_ptr<OPort0Type>(new OPort0Type());', "\n";
   print '				}', "\n";
   print '				otuplePtr->set_';
   print $name;
   print '(errorMsg);', "\n";
   print '			}', "\n";
   print '		}', "\n";
   print '		  ';
   }
   	  }
   	}
   print "\n";
   print '	if(errorFound) submit(*otuplePtr, 0);', "\n";
   print '}', "\n";
   print "\n";
   print '// static thread_specific_ptr initialization', "\n";
   print 'streams_boost::thread_specific_ptr<DBClientConnection> MY_OPERATOR_SCOPE::MY_OPERATOR::connPtr_;', "\n";
   print "\n";
   print 'DBClientConnection * MY_OPERATOR_SCOPE::MY_OPERATOR::getDBClientConnection(const string& db, const string& dbHost, uint32_t dbPort) {', "\n";
   print '	DBClientConnection * connPtr = connPtr_.get();', "\n";
   print '	if(!connPtr) {', "\n";
   print '		connPtr_.reset(new DBClientConnection(';
   print $autoReconnect;
   print ', 0, (double)';
   print $timeout;
   print '));', "\n";
   print '		connPtr = connPtr_.get();', "\n";
   print "\n";
   print '		std::string errmsg;', "\n";
   print '		try {', "\n";
   print '			connPtr->connect(buildConnUrl(dbHost, dbPort));', "\n";
   print '			', "\n";
   print '			';
   if ($authentication) {
   				BSONCommon::buildBSONObject($authentication->getSourceLocation(), $authentication->getCppExpression(), $authentication->getSPLType(), 0);
   print "\n";
   print '				connPtr->auth(b0.obj());', "\n";
   print '			';
   }
   			elsif ($username) {
   print "\n";
   print '				if(!connPtr->auth(db, ';
   print $username;
   print ', ';
   print $password;
   print ', errmsg)) {', "\n";
   print '					throw DBException(errmsg, 9999);', "\n";
   print '				}', "\n";
   print '			';
   }
   print "\n";
   print '		}', "\n";
   print '		catch( const DBException &e ) {', "\n";
   print '			if (';
   print $autoReconnect;
   print ')', "\n";
   print '				SPLAPPLOG(L_ERROR, e.what(), "MongoDB Connect");', "\n";
   print '			else', "\n";
   print '				THROW(SPL::SPLRuntimeOperator, e.what());', "\n";
   print '		}', "\n";
   print '	}', "\n";
   print '	return connPtr;', "\n";
   print '}', "\n";
   print "\n";
   SPL::CodeGen::implementationEpilogue($model);
   print "\n";
   CORE::exit $SPL::CodeGen::USER_ERROR if ($SPL::CodeGen::sawError);
}
1;
