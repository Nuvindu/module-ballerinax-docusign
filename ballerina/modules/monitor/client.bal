// Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;

# An API for an integrator to access the features of DocuSign Monitor
public isolated client class Client {
    final http:Client clientEp;
    final readonly & ApiKeysConfig apiKeyConfig;
    # Gets invoked to initialize the `connector`.
    #
    # + apiKeyConfig - API keys for authorization 
    # + config - The configurations to be used when initializing the `connector` 
    # + serviceUrl - URL of the target service 
    # + return - An error if connector initialization failed 
    public isolated function init(ApiKeysConfig apiKeyConfig, ConnectionConfig config =  {}, string serviceUrl = "https://lens.docusign.net/restapi") returns error? {
        http:ClientConfiguration httpClientConfig = {httpVersion: config.httpVersion, timeout: config.timeout, forwarded: config.forwarded, poolConfig: config.poolConfig, compression: config.compression, circuitBreaker: config.circuitBreaker, retryConfig: config.retryConfig, validation: config.validation};
        do {
            if config.http1Settings is ClientHttp1Settings {
                ClientHttp1Settings settings = check config.http1Settings.ensureType(ClientHttp1Settings);
                httpClientConfig.http1Settings = {...settings};
            }
            if config.http2Settings is http:ClientHttp2Settings {
                httpClientConfig.http2Settings = check config.http2Settings.ensureType(http:ClientHttp2Settings);
            }
            if config.cache is http:CacheConfig {
                httpClientConfig.cache = check config.cache.ensureType(http:CacheConfig);
            }
            if config.responseLimits is http:ResponseLimitConfigs {
                httpClientConfig.responseLimits = check config.responseLimits.ensureType(http:ResponseLimitConfigs);
            }
            if config.secureSocket is http:ClientSecureSocket {
                httpClientConfig.secureSocket = check config.secureSocket.ensureType(http:ClientSecureSocket);
            }
            if config.proxy is http:ProxyConfig {
                httpClientConfig.proxy = check config.proxy.ensureType(http:ProxyConfig);
            }
        }
        http:Client httpEp = check new (serviceUrl, httpClientConfig);
        self.clientEp = httpEp;
        self.apiKeyConfig = apiKeyConfig.cloneReadOnly();
        return;
    }
    # Gets customer event data for an organization.
    #
    # + dataSetName - Must be `monitor`.
    # + version - Must be `2`.
    # + cursor - Specifies a pointer into the dataset where your query will begin. You can either provide an ISO DateTime or a string cursor (from the `endCursor` value in the response). If no value is provided, the query begins from seven days ago.
    # For example, to fetch event data beginning from January 1, 2022, set this value to `2022-01-01T00:00:00Z`. The response will include data about events starting from that date in chronological order. The response also includes an `endCursor` property. To fetch the next page of event data, call this endpoint again with `cursor` set to the previous `endCursor` value.
    # + 'limit - The maximum number of records to return. The default value is 1000.
    # + return - Success 
    resource isolated function get api/[string version]/datasets/[string dataSetName]/'stream(string? cursor = (), int:Signed32 'limit = 1000) returns CursoredResult|error {
        string resourcePath = string `/api/v${getEncodedUri(version)}/datasets/${getEncodedUri(dataSetName)}/stream`;
        map<anydata> queryParam = {"cursor": cursor, "limit": 'limit};
        resourcePath = resourcePath + check getPathForQueryParam(queryParam);
        CursoredResult response = check self.clientEp->get(resourcePath);
        return response;
    }
}
