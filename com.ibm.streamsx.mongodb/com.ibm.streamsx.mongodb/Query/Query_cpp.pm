
package Query_cpp;
use strict; use Cwd 'realpath';  use File::Basename;  use lib dirname(__FILE__);  use SPL::Operator::Instance::OperatorInstance; use SPL::Operator::Instance::Context; use SPL::Operator::Instance::Expression; use SPL::Operator::Instance::ExpressionTree; use SPL::Operator::Instance::ExpressionTreeVisitor; use SPL::Operator::Instance::ExpressionTreeCppGenVisitor; use SPL::Operator::Instance::InputAttribute; use SPL::Operator::Instance::InputPort; use SPL::Operator::Instance::OutputAttribute; use SPL::Operator::Instance::OutputPort; use SPL::Operator::Instance::Parameter; use SPL::Operator::Instance::StateVariable; use SPL::Operator::Instance::Window; 
sub main::generate($$) {
   my ($xml, $signature) = @_;  
   print "// $$signature\n";
   my $model = SPL::Operator::Instance::OperatorInstance->new($$xml);
   unshift @INC, dirname ($model->getContext()->getOperatorDirectory()) . "/../impl/nl/include";
   $SPL::CodeGenHelper::verboseMode = $model->getContext()->isVerboseModeOn();
   SPL::CodeGen::implementationPrologue($model);
   print "\n";
   print "\n";
   	use QueryCommon;
   
   	my $db = $model->getParameterByName('dbName')->getValueAt(0)->getCppExpression();
   	my $collection = $model->getParameterByName('collection')->getValueAt(0)->getCppExpression();
   
   	my $dbHost = $model->getParameterByName('dbHost')->getValueAt(0)->getCppExpression();
   
   	my $dbPortParam = $model->getParameterByName('dbPort');
   	my $dbPort = (defined $dbPortParam) ? $dbPortParam->getValueAt(0)->getCppExpression() : 27017;
   
   	my $findFieldsParam = $model->getParameterByName('findFields');
   	my $findFields = (defined $findFieldsParam) ? '&'.$findFieldsParam->getValueAt(0)->getCppExpression() : 'NULL';
   
   	my $findQueryParam = $model->getParameterByName('findQuery');
   	my $findQueryExpr = $findQueryParam->getValueAt(0);
   	my $findQuery = (defined $findQueryParam) ? $findQueryExpr->getCppExpression() : 'BSONObj()';
   	SPL::CodeGen::errorln("The type '%s' of findQuery parameter is not map or tuple.",
   			$findQueryExpr->getSPLType(), $findQueryExpr->getSourceLocation())
   			if (defined $findQueryParam && QueryCommon::keyLess($findQueryExpr->getSPLType()));
   
   	my $timeoutParam = $model->getParameterByName('timeout');
   	my $timeout = (defined $timeoutParam) ? $timeoutParam->getValueAt(0)->getCppExpression() : 0.0;
   
   	my $ignoreDocumentIdParam = $model->getParameterByName('ignoreDocumentId');
   	my $ignoreDocumentId = (defined $ignoreDocumentIdParam) ? $ignoreDocumentIdParam->getValueAt(0)->getCppExpression() : 'true';
   
   	my $inputPort = $model->getInputPortAt(0);
   	my $outputPort = $model->getOutputPortAt(0);
   	my $inTuple = $inputPort->getCppTupleName();
   print "\n";
   print "\n";
   print 'string MY_OPERATOR_SCOPE::MY_OPERATOR::buildConnUrl(const string& dbHost, uint32_t dbPort) {', "\n";
   print '	string connUrl = dbHost;', "\n";
   print '	connUrl += ":"; ', "\n";
   print '	connUrl += spl_cast<rstring,uint32_t>::cast(dbPort);', "\n";
   print '	return connUrl;', "\n";
   print '}', "\n";
   print "\n";
   print 'string MY_OPERATOR_SCOPE::MY_OPERATOR::buildDbCollection(const string& db, const string& collection) {', "\n";
   print '	string dbCollection(db);', "\n";
   print '	dbCollection += ".";', "\n";
   print '	dbCollection += collection;', "\n";
   print '	return dbCollection;', "\n";
   print '}', "\n";
   print "\n";
   print 'BSONObj MY_OPERATOR_SCOPE::MY_OPERATOR::buildFindQueryBO() {', "\n";
   if (defined $findQueryParam) {
   	QueryCommon::buildBSONObject($model, $findQueryExpr->getSourceLocation(), $findQueryExpr->getCppExpression(), $findQueryExpr->getSPLType(), 0);
   print "\n";
   print '	return b0.obj();', "\n";
   }
     else {
   print "\n";
   print '	return BSONObj();', "\n";
   }
   print "\n";
   print '}', "\n";
   print "\n";
   print 'MY_OPERATOR_SCOPE::MY_OPERATOR::MY_OPERATOR() : findQueryBO_(buildFindQueryBO()) {', "\n";
   print '	try {', "\n";
   print '		ScopedDbConnection conn(buildConnUrl(';
   print $dbHost;
   print ', ';
   print $dbPort;
   print '), (double)';
   print $timeout;
   print ');', "\n";
   print '		if(!conn.ok()) {', "\n";
   print '			THROW(SPL::SPLRuntimeOperator, "MongoDB create connection failed");', "\n";
   print '		}', "\n";
   print '		conn.done();', "\n";
   print '	}', "\n";
   print '	catch( const DBException &e ) {', "\n";
   print '		THROW(SPL::SPLRuntimeOperator, e.what());', "\n";
   print '	}', "\n";
   print '}', "\n";
   print "\n";
   print 'MY_OPERATOR_SCOPE::MY_OPERATOR::~MY_OPERATOR() {}', "\n";
   print "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::allPortsReady() {}', "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::prepareToShutdown() {}', "\n";
   print "\n";
   print 'void MY_OPERATOR_SCOPE::MY_OPERATOR::process(Tuple const & tuple, uint32_t port) {', "\n";
   print '	';
   for (my $i = 0; $i < $model->getNumberOfInputPorts(); $i++) {
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
   print '	OPort0Type * otuplePtr = getOutputTuple();', "\n";
   print '	', "\n";
   print '	';
   foreach my $attribute (@{$outputPort->getAttributes()}) {
   	  my $attrName = $attribute->getName();
   	  if ($attribute->hasAssignmentWithOutputFunction()) {
   	  	if ($attribute->getAssignmentOutputFunctionName() eq 'AsIs') {
   			my $assign = $attribute->getAssignmentOutputFunctionParameterValueAt(0)->getCppExpression();
   print "\n";
   print '			otuplePtr->set_';
   print $attrName;
   print '(';
   print $assign;
   print ');', "\n";
   print '		';
   }
   	  }
   	  elsif ($attribute->hasAssignment()) {
   			my $assign = $attribute->getAssignmentValue()->getCppExpression();
   print "\n";
   print '			otuplePtr->set_';
   print $attrName;
   print '(';
   print $assign;
   print ');', "\n";
   print '	  ';
   }
   	}
   print "\n";
   print "\n";
   print '	streams_boost::scoped_ptr<ScopedDbConnection> conn;', "\n";
   print '	BSONObj queryResultBO;', "\n";
   print '	bool docFound = false;', "\n";
   print '	', "\n";
   print '	rstring errorMsg = "";', "\n";
   print '	try {', "\n";
   print '		conn.reset(new ScopedDbConnection(buildConnUrl(';
   print $dbHost;
   print ', ';
   print $dbPort;
   print '), (double)';
   print $timeout;
   print '));', "\n";
   print "\n";
   print '		if(!conn->ok()) {', "\n";
   print '			errorMsg = "MongoDB create connection failed";', "\n";
   print '		}', "\n";
   print '	}', "\n";
   print '	catch( const DBException &e ) {', "\n";
   print '		errorMsg = e.what();', "\n";
   print '	}', "\n";
   print "\n";
   print '	if (errorMsg != "") {', "\n";
   print '		SPLAPPLOG(L_ERROR, error, "MongoDB Query");', "\n";
   print '	}', "\n";
   print "\n";
   print '	if(conn->ok()) {', "\n";
   print '		streams_boost::scoped_ptr<DBClientCursor> cursor((*conn)->query(buildDbCollection(';
   print $db;
   print ', ';
   print $collection;
   print '), ';
   print $findQuery;
   print '));', "\n";
   print '		docFound = cursor->more();', "\n";
   print '		while (cursor->more()) {', "\n";
   print '			queryResultBO = cursor->next();', "\n";
   print '			OPort0Type otuple(*otuplePtr);', "\n";
   print "\n";
   # [----- perl code -----]
   		foreach my $attribute (@{$outputPort->getAttributes()}) {
   			my $attrName = $attribute->getName();
   			if ($attribute->hasAssignmentWithOutputFunction() && ($attribute->getAssignmentOutputFunctionName() ne 'AsIs')) {
   				my $numberOfParams = @{$attribute->getAssignmentOutputFunctionParameterValues};
   				my $exprLocation = $attribute->getAssignmentSourceLocation();
   				my $cppType = $attribute->getCppType();
   				my $splType = $attribute->getSPLType();
   				if ($numberOfParams > 0) {
   					my $findExpr = $attribute->getAssignmentOutputFunctionParameterValueAt(0);
   					my $findExprLocation = $findExpr->getSourceLocation();
   					my $findCppExpr = $findExpr->getCppExpression();
   					my $findSplType = $findExpr->getSPLType();
   				}
   
   				QueryCommon::initBSONObject($attrName, $cppType);
   
   				QueryCommon::handleBSONObject($exprLocation, $attrName, $splType, 0);
   
   				QueryCommon::endBSONObject();
   			}
   		}
   # [----- perl code -----]
   print "\n";
   print "\n";
   print '			submit(otuple, 0);', "\n";
   print '		}', "\n";
   print '		conn->done();', "\n";
   print '	}', "\n";
   print "\n";
   print '	if(!docFound) submit(*otuplePtr, 0);', "\n";
   print '}', "\n";
   print "\n";
   print 'streams_boost::thread_specific_ptr<MY_OPERATOR_SCOPE::MY_OPERATOR::OPort0Type> MY_OPERATOR_SCOPE::MY_OPERATOR::otuplePtr_;', "\n";
   print "\n";
   print 'MY_OPERATOR_SCOPE::MY_OPERATOR::OPort0Type * MY_OPERATOR_SCOPE::MY_OPERATOR::getOutputTuple() {', "\n";
   print '	OPort0Type * otuplePtr = otuplePtr_.get();', "\n";
   print '	if(!otuplePtr) {', "\n";
   print '		otuplePtr_.reset(new OPort0Type());', "\n";
   print '		otuplePtr = otuplePtr_.get();', "\n";
   print '	}', "\n";
   print '	return otuplePtr;', "\n";
   print '}', "\n";
   print "\n";
   SPL::CodeGen::implementationEpilogue($model);
   print "\n";
   CORE::exit $SPL::CodeGen::USER_ERROR if ($SPL::CodeGen::sawError);
}
1;
